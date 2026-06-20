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
            if splashState.isFinished {
                TabBarView()
                    .background(Colors.brandDark)
                    .environment(languageClient)
                    .environment(\.languageBundle, languageClient.bundle)
                    .environment(themeClient)
                    .environment(premiumClient)
                    .environment(coordinator)
                    .environment(questionHolder)
                    .environment(likesStore)
                    .preferredColorScheme(themeClient.current.colorScheme)
            } else {
                SplashView(state: splashState)
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
    }
}
