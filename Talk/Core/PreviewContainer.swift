#if DEBUG
import SwiftUI

struct PreviewContainer<Content: View>: View {
    @State private var questionHolder = QuestionClientHolder()
    @State private var languageClient = LanguageClient()
    @State private var themeClient = ThemeClient()
    @State private var premiumClient = PremiumClient()
    @State private var coordinator = AppCoordinator()

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .environment(languageClient)
            .environment(\.languageBundle, languageClient.bundle)
            .environment(themeClient)
            .environment(premiumClient)
            .environment(coordinator)
            .environment(questionHolder)
    }
}
#endif
