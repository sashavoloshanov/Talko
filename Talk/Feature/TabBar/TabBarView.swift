import SwiftUI

struct TabBarView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(ThemeClient.self) private var themeClient
    @State private var selectedTab: AppTab = .home

    var body: some View {
        @Bindable var coord = coordinator

        NavigationStack(path: $coord.path) {
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .badges:
                        BadgesView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Colors.backgroundPrimary)

                LiquidGlassTabBar(selectedTab: $selectedTab)
                
                if case let .badge(badge) = coord.fullScreenCover {
                    BadgeDetailView(badge: badge)
                        .zIndex(1000)
                        .transition(.opacity)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .question(let questions, let subcategoryId, let title):
                    QuestionView(questions: questions, subcategoryId: subcategoryId, title: title)
                        .background(Colors.backgroundPrimary)

                case .likedQuestions:
                    LikedQuestionsView()
                        .background(Colors.backgroundPrimary)
                }
            }
            .sheet(item: $coord.sheet) { screen in
                switch screen {
                case .document(let item):
                    DocumentView(document: item)

                case .subscription:
                    SubscriptionView()
                }
            }
            .animation(.easeInOut(duration: 0.2), value: coord.fullScreenCover != nil)
        }
        .preferredColorScheme(themeClient.current.colorScheme)
    }
}
