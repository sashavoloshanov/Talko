import SwiftUI

struct HomeView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(QuestionClientHolder.self) private var questionHolder
    @Environment(LanguageClient.self) private var languageClient
    @Environment(\.languageBundle) private var bundle
    @Environment(PremiumClient.self) private var premiumClient
    @Environment(LikesStore.self) private var likesStore
    @State private var viewModel = HomeViewModel()

    var body: some View {
        VStack(spacing: 0) {
            navigationView
            contentView
        }
        .onAppear {
            Task { await viewModel.loadContent(holder: questionHolder, language: languageClient.current, premiumClient: premiumClient, likesStore: likesStore) }
        }
        .onChange(of: viewModel.errorMessage) { _, msg in
            guard msg != nil, !questionHolder.isLoading else { return }
            viewModel.errorMessage = nil
            Task { await viewModel.reloadContent(holder: questionHolder, language: languageClient.current, premiumClient: premiumClient, likesStore: likesStore) }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if questionHolder.categories.isEmpty {
            Spacer()
            ProgressView()
                .tint(Colors.textPrimary)
            Spacer()
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

    private var navigationView: some View {
        NavigationBar(
            leftButton: nil,
            centerContent: .text("Talko"),
            rightButton: viewModel.hasLikedQuestions(likesStore) ? NavRightButton(
                icon: UIImage(systemName: "heart.fill") ?? UIImage(),
                action: { coordinator.push(.likedQuestions) }
            ) : nil
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
            coordinator.push(.question(subcategoryId: subcategory.id, title: subcategory.name))
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
