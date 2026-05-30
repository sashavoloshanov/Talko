import Foundation
 
enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case badges
    case settings
 
    var id: Int { rawValue }
 
    func title(in bundle: Bundle) -> String {
        switch self {
        case .home: return String(localized: "tab_home", bundle: bundle)
        case .badges: return String(localized: "tab_badges", bundle: bundle)
        case .settings: return String(localized: "tab_settings", bundle: bundle)
        }
    }
 
    var icon: String {
        switch self {
        case .home: return "homeIcon"
        case .badges: return "badgeIcon"
        case .settings: return "settingsIcon"
        }
    }
}
