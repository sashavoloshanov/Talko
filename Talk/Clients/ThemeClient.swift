import Foundation
import SwiftUI
import Combine
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
 
    private let subject: CurrentValueSubject<AppTheme, Never>
    let themePublisher: AnyPublisher<AppTheme, Never>
 
    init() {
        let saved = UserDefaultsClient.get(AppTheme.self, for: .appTheme) ?? .light
        self.current = saved
        let subj = CurrentValueSubject<AppTheme, Never>(saved)
        self.subject = subj
        self.themePublisher = subj.eraseToAnyPublisher()
    }
 
    func setTheme(_ theme: AppTheme) {
        current = theme
        UserDefaultsClient.set(theme, for: .appTheme)
        subject.send(theme)
    }
}
