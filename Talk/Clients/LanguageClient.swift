import Foundation
import Observation
import WidgetKit
 
enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case ukrainian = "uk"
    case english = "en"
 
    var id: String { rawValue }
 
    var displayName: String {
        switch self {
        case .ukrainian: return "Українська"
        case .english: return "English"
        }
    }
}
 
@Observable
final class LanguageClient {
    private(set) var current: AppLanguage
 
    var bundle: Bundle {
        Bundle(path: Bundle.main.path(forResource: current.rawValue, ofType: "lproj") ?? "") ?? .main
    }
 
    init() {
        self.current = UserDefaultsClient.get(AppLanguage.self, for: .appLanguage) ?? .ukrainian
    }
 
    func setLanguage(_ lang: AppLanguage) {
        current = lang
        UserDefaultsClient.set(lang, for: .appLanguage)
        UserDefaults(suiteName: AppGroupKey.suiteName)?.set(lang.rawValue, forKey: AppGroupKey.appLanguage)
        Task {
            await QuestionClient.shared.refreshWidgetData(for: lang)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
