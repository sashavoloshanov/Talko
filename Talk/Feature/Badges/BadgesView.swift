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
            contentView
        }
        .background(Color.backgroundPrimary)
        .onAppear {
            viewModel.setup(holder: questionHolder, languageClient: languageClient, premiumClient: premiumClient)
            viewModel.load(categories: questionHolder.categories)
        }
        .onChange(of: questionHolder.categories) { _, cats in
            viewModel.load(categories: cats)
        }
        .onChange(of: premiumClient.isPremium) { _, _ in
            viewModel.load(categories: questionHolder.categories)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if questionHolder.isLoading && viewModel.categories.isEmpty {
            Spacer()
            ProgressView()
            Spacer()
        } else {
            scrollContent
        }
    }

    private var scrollContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(viewModel.categories) { category in
                    let badges = viewModel.badgesByCategory[category.id] ?? []
                    if !badges.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            CategorySectionHeader(emoji: category.emoji, name: category.name)

                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible()), count: 3),
                                spacing: 0
                            ) {
                                ForEach(badges) { badge in
                                    BadgeRow(badge: badge) {
                                        coordinator.present(.badge(badge))
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
