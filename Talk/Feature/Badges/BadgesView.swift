import SwiftUI

struct BadgesView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(QuestionClientHolder.self) private var questionHolder
    @Environment(LanguageClient.self) private var languageClient
    @Environment(\.languageBundle) private var bundle
    @State private var viewModel = BadgesViewModel()

    var body: some View {
        VStack(spacing: 0) {
            navigationView

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(viewModel.categories) { category in
                        let badges = viewModel.badgesByCategory[category.id] ?? []
                        if !badges.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionHeader(with: category)

                                LazyVGrid(
                                    columns: Array(repeating: GridItem(.flexible()), count: 4),
                                    spacing: 0
                                ) {
                                    ForEach(badges) { badge in
                                        BadgeRow(badge: badge) {
                                            if badge.isEarned {
                                                coordinator.present(.badge(badge))
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.top, 16)
            }
        }
        .background(Color.backgroundPrimary)
        .onAppear {
            viewModel.setup(holder: questionHolder, languageClient: languageClient)
        }
        .onChange(of: languageClient.current) { _, newLang in
            viewModel.reload(holder: questionHolder, language: newLang)
        }
    }
    
    private var navigationView: some View {
        NavigationBar(
            leftButton: nil,
            centerContent: .text(String(localized: "tab_badges", bundle: bundle)),
            rightButton: nil
        )
    }
    
    private func sectionHeader(with category: Category) -> some View {
        HStack(spacing: 8) {
            Text(category.emoji)
                .font(.title2)
            Text(category.name)
                .font(.title2.bold())
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
#Preview("Dark") {
    @Previewable @State var questionHolder = QuestionClientHolder()
    @Previewable @State var languageClient = LanguageClient()
    @Previewable @State var themeClient = ThemeClient()
    @Previewable @State var premiumClient = PremiumClient()
    @Previewable @State var coordinator = AppCoordinator()
    
    BadgesView()
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
    
    BadgesView()
        .environment(languageClient)
        .environment(\.languageBundle, languageClient.bundle)
        .environment(themeClient)
        .environment(premiumClient)
        .environment(coordinator)
        .environment(questionHolder)
        .preferredColorScheme(ColorScheme.light)
}
#endif
