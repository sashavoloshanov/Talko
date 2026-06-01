import SwiftUI

struct BadgesView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(QuestionClientHolder.self) private var questionHolder
    @Environment(LanguageClient.self) private var languageClient
    @Environment(PremiumClient.self) private var premiumClient
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
                                CategorySectionHeader(emoji: category.emoji, name: category.name)

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
            viewModel.load(categories: questionHolder.categories)
            Task { try? await questionHolder.load(language: languageClient.current, premiumClient: premiumClient) }
        }
        .onChange(of: questionHolder.categories) { _, cats in
            viewModel.load(categories: cats)
        }
        .onChange(of: languageClient.current) { _, newLang in
            Task { try? await questionHolder.load(language: newLang, premiumClient: premiumClient) }
        }
    }
    
    private var navigationView: some View {
        NavigationBar(
            leftButton: nil,
            centerContent: .text(String(localized: "tab_badges", bundle: bundle)),
            rightButton: nil
        )
    }
}

#if DEBUG
#Preview("Dark") {
    PreviewContainer(scheme: .dark) { BadgesView() }
}

#Preview("Light") {
    PreviewContainer(scheme: .light) { BadgesView() }
}
#endif
