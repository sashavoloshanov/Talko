import Foundation

enum DocumentItem: Hashable {
    case privacyPolicy
    case termsOfService

    func fileName(_ language: AppLanguage) -> String {
        switch self {
        case .privacyPolicy:
            return language == .ukrainian ? "privacy_policy_ua" : "privacy_policy_en"
        case .termsOfService:
            return language == .ukrainian ? "terms_of_use_ua" : "terms_of_use_en"
        }
    }
    
    func localURL(_ language: AppLanguage) -> URL? {
        Bundle.main.url(forResource: fileName(language), withExtension: "html")
    }
}
