import Foundation

enum WidgetFallback {
    /// Shown when a category widget has no cached questions in the App Group yet.
    static var reload: String {
        String(localized: "widget_fallback_reload", defaultValue: "Reload", bundle: languageBundle)
    }

    /// Shown when daily.json can't be loaded from the widget bundle.
    static var dailyQuestion: String {
        String(localized: "widget_fallback_daily_question", defaultValue: "What made you happy today?", bundle: languageBundle)
    }

    // Placeholder text shown before the first timeline loads. Localized so the
    // widget never displays an empty/English-only state.
    static var placeholderDailyQuestion: String { dailyQuestion }
    static var placeholderCategoryQuestion: String { reload }

    // Widgets follow the language selected in the app (App Group), not the system locale.
    private static var languageBundle: Bundle {
        let code = UserDefaults(suiteName: AppGroupKey.suiteName)?.string(forKey: AppGroupKey.appLanguage) ?? "uk"
        return Bundle(path: Bundle.main.path(forResource: code, ofType: "lproj") ?? "") ?? .main
    }
}
