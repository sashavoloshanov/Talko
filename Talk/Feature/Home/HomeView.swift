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

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    if let daily = questionHolder.dailyQuestion {
                        dailyView(daily)
                    }

                    ForEach(questionHolder.categories) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader(with: category.emoji, and: category.name)

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
        .onAppear {
            Task { try? await questionHolder.load(language: languageClient.current, premiumClient: premiumClient) }
        }
        .onChange(of: languageClient.current) { _, newLang in
            Task { try? await questionHolder.load(language: newLang, premiumClient: premiumClient) }
        }
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
    
    private func sectionHeader(with emoji: String, and name: String) -> some View {
        HStack(spacing: 8) {
            Text(emoji)
                .font(.title2)
            Text(name)
                .font(.title2.bold())
        }
        .padding(.horizontal, 16)
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
    PreviewContainer { HomeView() }
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    PreviewContainer { HomeView() }
        .preferredColorScheme(.light)
}
#endif
