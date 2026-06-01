import Foundation
import Combine
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
 
    private let subject: CurrentValueSubject<AppLanguage, Never>
    let languagePublisher: AnyPublisher<AppLanguage, Never>
    
    var bundle: Bundle {
        Bundle(path: Bundle.main.path(forResource: current.rawValue, ofType: "lproj") ?? "") ?? .main
    }
 
    init() {
        let saved = UserDefaultsClient.get(AppLanguage.self, for: .appLanguage) ?? .ukrainian
        self.current = saved
        let subj = CurrentValueSubject<AppLanguage, Never>(saved)
        self.subject = subj
        self.languagePublisher = subj.eraseToAnyPublisher()
    }
 
    func setLanguage(_ lang: AppLanguage) {
        current = lang
        UserDefaultsClient.set(lang, for: .appLanguage)
        UserDefaults(suiteName: AppGroupKey.suiteName)?.set(lang.rawValue, forKey: AppGroupKey.appLanguage)
        subject.send(lang)
        Task {
            await QuestionClient.shared.refreshWidgetData(for: lang)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
