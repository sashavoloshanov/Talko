import SwiftUI
 
extension View {
    func hideTabBar() -> some View {
        self.toolbar(.hidden, for: .tabBar)
    }
}
 
extension UIApplication {
    static var safeAreaBottomInset: CGFloat {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
        return scene?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}

private struct LanguageBundleKey: EnvironmentKey {
    static let defaultValue: Bundle = .main
}

extension EnvironmentValues {
    var languageBundle: Bundle {
        get { self[LanguageBundleKey.self] }
        set { self[LanguageBundleKey.self] = newValue }
    }
}
