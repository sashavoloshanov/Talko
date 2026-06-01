import Foundation
import SwiftUI
import Observation
 
enum AppTheme: String, CaseIterable, Codable, Identifiable {
    case light
    case dark
 
    var id: String { rawValue }
 
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
 
    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}
 
@Observable
final class ThemeClient {
    private(set) var current: AppTheme
 
    init() {
        self.current = UserDefaultsClient.get(AppTheme.self, for: .appTheme) ?? .light
    }
 
    func setTheme(_ theme: AppTheme) {
        current = theme
        UserDefaultsClient.set(theme, for: .appTheme)
    }
}
