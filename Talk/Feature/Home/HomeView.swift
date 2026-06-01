import SwiftUI

struct HomeView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(QuestionClientHolder.self) private var questionHolder
    @Environment(LanguageClient.self) private var languageClient
    @Environment(\.languageBundle) private var bundle
    @Environment(PremiumClient.self) private var premiumClient
    @State private var viewModel = HomeViewModel()

    var body: some View {
        VStack(spacing: 0) {
            navigationView
            contentView
        }
        .onAppear {
            Task { await viewModel.loadContent(holder: questionHolder, language: languageClient.current, premiumClient: premiumClient) }
        }
        .onChange(of: languageClient.current) { _, newLang in
            Task { await viewModel.loadContent(holder: questionHolder, language: newLang, premiumClient: premiumClient) }
        }
        .alert(
            String(localized: "common_error_title", bundle: bundle),
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(String(localized: "common_retry", bundle: bundle)) {
                Task { await viewModel.reloadContent(holder: questionHolder, language: languageClient.current, premiumClient: premiumClient) }
            }
            Button(String(localized: "common_cancel", bundle: bundle), role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if questionHolder.isLoading && questionHolder.categories.isEmpty {
            Spacer()
            ProgressView()
            Spacer()
        } else if !questionHolder.isLoading && questionHolder.categories.isEmpty {
            emptyView
        } else {
            scrollContent
        }
    }

    private var scrollContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                if let daily = questionHolder.dailyQuestion {
                    dailyView(daily)
                }

                ForEach(questionHolder.categories) { category in
                    VStack(alignment: .leading, spacing: 12) {
                        CategorySectionHeader(emoji: category.emoji, name: category.name)

                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 12
                        ) {
                            ForEach(category.subcategories) { sub in
                                listRow(sub)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }

                Spacer().frame(height: 100)
            }
            .padding(.top, 16)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(String(localized: "home_empty_title", bundle: bundle))
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(String(localized: "home_empty_description", bundle: bundle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(String(localized: "common_retry", bundle: bundle)) {
                Task { await viewModel.reloadContent(holder: questionHolder, language: languageClient.current, premiumClient: premiumClient) }
            }
            .buttonStyle(.bordered)
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private var navigationView: some View {
        NavigationBar(
            leftButton: nil,
            centerContent: .text("Talk"),
            rightButton: NavRightButton(
                icon: UIImage(systemName: "heart.fill") ?? UIImage(),
                action: { coordinator.push(.likedQuestions) }
            )
        )
    }
    
    private func dailyView(_ daily: DailyQuestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "home_daily_question_title", bundle: bundle))
                .font(.headline)
                .padding(.horizontal, 16)

            DailyQuestionCard(question: daily)
                .padding(.horizontal, 16)
        }
    }
    
    private func listRow(_ subcategory: Subcategory) -> some View {
        SubcategoryRow(subcategory: subcategory) {
            if viewModel.isLocked(subcategory, isPremium: premiumClient.isPremium) {
                coordinator.present(.subscription)
                return
            }
            let questions = viewModel.questionsForSubcategory(subcategory)
            coordinator.push(.question(questions, subcategoryId: subcategory.id, title: subcategory.name))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 8)
    }
}

#if DEBUG
#Preview("Dark") {
    PreviewContainer(scheme: .dark) { HomeView() }
}

#Preview("Light") {
    PreviewContainer(scheme: .light) { HomeView() }
}
#endif
