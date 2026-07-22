import SwiftUI

struct TabBarView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(ThemeClient.self) private var themeClient
    @Environment(QuestionClientHolder.self) private var questionHolder
    @Environment(LanguageClient.self) private var languageClient
    @Environment(PremiumClient.self) private var premiumClient
    @State private var selectedTab: AppTab = .home

    var body: some View {
        @Bindable var coord = coordinator

        NavigationStack(path: $coord.path) {
            currentTab
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Colors.backgroundPrimary)
                .overlay(alignment: .bottom) { LiquidGlassTabBar(selectedTab: $selectedTab) }
                .overlay { badgeOverlay }
                .ignoresSafeArea(edges: .bottom)
                .navigationDestination(for: AppRoute.self, destination: routeView)
                .sheet(item: $coord.sheet, content: sheetView)
                .animation(.easeInOut(duration: 0.2), value: coordinator.fullScreenCover != nil)
        }
        .preferredColorScheme(themeClient.current.colorScheme)
        .onChange(of: languageClient.current) { _, newLang in
            Task {
                questionHolder.reload()
                try? await questionHolder.load(language: newLang)
            }
        }
    }

    @ViewBuilder
    private var currentTab: some View {
        switch selectedTab {
        case .home:     HomeView()
        case .badges:   BadgesView()
        case .settings: SettingsView()
        }
    }

    @ViewBuilder
    private var badgeOverlay: some View {
        if case let .badge(badge) = coordinator.fullScreenCover {
            BadgeDetailView(badge: badge)
                .zIndex(1000)
                .transition(.opacity)
        }
    }

    @ViewBuilder
    private func routeView(_ route: AppRoute) -> some View {
        switch route {
        case .question(let subcategoryId, let title):
            let questions = questionHolder.subcategory(withId: subcategoryId)?.questions ?? []
            if questions.isEmpty {
                EmptyView().onAppear { coordinator.pop() }
            } else {
                QuestionView(questions: questions, subcategoryId: subcategoryId, title: title)
                    .background(Colors.backgroundPrimary)
            }
        case .likedQuestions:
            LikedQuestionsView()
                .background(Colors.backgroundPrimary)
        }
    }

    @ViewBuilder
    private func sheetView(_ screen: AppSheet) -> some View {
        switch screen {
        case .document(let item): DocumentView(document: item)
        case .subscription:       SubscriptionView()
        }
    }
}
