import SwiftUI

@main
struct TalkApp: App {
    @State private var splashState = SplashState()
    @State private var languageClient = LanguageClient()
    @State private var themeClient = ThemeClient()
    @State private var premiumClient = PremiumClient()
    @State private var coordinator = AppCoordinator()
    @State private var questionHolder = QuestionClientHolder()
    @State private var likesStore = LikesStore()

    init() {
        MigrationClient.runIfNeeded()
        let premiumClient = premiumClient
        Task { await premiumClient.checkPremiumStatus() }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if splashState.isFinished {
                    TabBarView()
                        .background(Colors.brandDark)
                } else {
                    SplashView(state: splashState)
                }
            }
            .appEnvironment(
                languageClient: languageClient,
                themeClient: themeClient,
                premiumClient: premiumClient,
                coordinator: coordinator,
                questionHolder: questionHolder,
                likesStore: likesStore
            )
        }
    }
}

private struct AppEnvironmentModifier: ViewModifier {
    let languageClient: LanguageClient
    let themeClient: ThemeClient
    let premiumClient: PremiumClient
    let coordinator: AppCoordinator
    let questionHolder: QuestionClientHolder
    let likesStore: LikesStore

    func body(content: Content) -> some View {
        content
            .environment(languageClient)
            .environment(\.languageBundle, languageClient.bundle)
            .environment(themeClient)
            .environment(premiumClient)
            .environment(coordinator)
            .environment(questionHolder)
            .environment(likesStore)
            .preferredColorScheme(themeClient.current.colorScheme)
    }
}

private extension View {
    func appEnvironment(
        languageClient: LanguageClient,
        themeClient: ThemeClient,
        premiumClient: PremiumClient,
        coordinator: AppCoordinator,
        questionHolder: QuestionClientHolder,
        likesStore: LikesStore
    ) -> some View {
        modifier(AppEnvironmentModifier(
            languageClient: languageClient,
            themeClient: themeClient,
            premiumClient: premiumClient,
            coordinator: coordinator,
            questionHolder: questionHolder,
            likesStore: likesStore
        ))
    }
}
