import Foundation

enum DocumentItem {
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

extension DocumentItem: Hashable {
    static func == (lhs: DocumentItem, rhs: DocumentItem) -> Bool {
        switch (lhs, rhs) {
        case (.privacyPolicy, .privacyPolicy),
             (.termsOfService, .termsOfService): return true
        default: return false
        }
    }
    func hash(into hasher: inout Hasher) {
        switch self {
        case .privacyPolicy:  hasher.combine(0)
        case .termsOfService: hasher.combine(1)
        }
    }
}
