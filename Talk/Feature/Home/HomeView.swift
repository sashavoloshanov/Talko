import SwiftUI

struct HomeView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(QuestionClientHolder.self) private var questionHolder
    @Environment(LanguageClient.self) private var languageClient
    @Environment(\.languageBundle) private var bundle
    @Environment(PremiumClient.self) private var premiumClient
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
            guard !subcategory.isPremium || !premiumClient.isPremium else {
                coordinator.present(.subscription)
                return
            }
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress) ?? [:]
            let lastIndex = progress[subcategory.id] ?? 0
            let startIndex = min(lastIndex, subcategory.questions.count - 1)
            let questions = Array(subcategory.questions.dropFirst(startIndex)) + Array(subcategory.questions.prefix(startIndex))
            coordinator.push(.question(questions, subcategoryId: subcategory.id, title: subcategory.name))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 8)
    }
}

#if DEBUG
#Preview("Dark") {
    @Previewable @State var questionHolder = QuestionClientHolder()
    @Previewable @State var languageClient = LanguageClient()
    @Previewable @State var themeClient = ThemeClient()
    @Previewable @State var premiumClient = PremiumClient()
    @Previewable @State var coordinator = AppCoordinator()
    
    HomeView()
        .environment(languageClient)
        .environment(\.languageBundle, languageClient.bundle)
        .environment(themeClient)
        .environment(premiumClient)
        .environment(coordinator)
        .environment(questionHolder)
        .preferredColorScheme(ColorScheme.dark)
}

#Preview("Light") {
    @Previewable @State var questionHolder = QuestionClientHolder()
    @Previewable @State var languageClient = LanguageClient()
    @Previewable @State var themeClient = ThemeClient()
    @Previewable @State var premiumClient = PremiumClient()
    @Previewable @State var coordinator = AppCoordinator()
    
    HomeView()
        .environment(languageClient)
        .environment(\.languageBundle, languageClient.bundle)
        .environment(themeClient)
        .environment(premiumClient)
        .environment(coordinator)
        .environment(questionHolder)
        .preferredColorScheme(ColorScheme.light)
}
#endif
