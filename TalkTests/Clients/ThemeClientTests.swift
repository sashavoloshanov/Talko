import Testing
import Foundation
internal import SwiftUI
@testable import Talk

@Suite("ThemeClient", .serialized)
@MainActor
struct ThemeClientTests {

    @Suite("AppTheme")
    @MainActor
    struct AppThemeEnum {
        @Test func rawValues() {
            #expect(AppTheme.light.rawValue == "light")
            #expect(AppTheme.dark.rawValue == "dark")
        }

        @Test func displayNames() {
            #expect(AppTheme.light.displayName == "Light")
            #expect(AppTheme.dark.displayName == "Dark")
        }

        @Test func idEqualsRawValue() {
            for theme in AppTheme.allCases {
                #expect(theme.id == theme.rawValue)
            }
        }

        @Test func colorSchemes() {
            #expect(AppTheme.light.colorScheme == .light)
            #expect(AppTheme.dark.colorScheme == .dark)
        }
    }

    @Suite("init")
    @MainActor
    struct Init {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.theme.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func noSavedTheme_defaultsToLight() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let client = ThemeClient()
            #expect(client.current == .light)
        }

        @Test func savedDarkTheme_restoresDark() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(AppTheme.dark, for: .appTheme)
            UserDefaultsClient.defaults = defaults
            let client = ThemeClient()
            #expect(client.current == .dark)
        }

        @Test func savedLightTheme_restoresLight() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(AppTheme.light, for: .appTheme)
            UserDefaultsClient.defaults = defaults
            let client = ThemeClient()
            #expect(client.current == .light)
        }
    }

    @Suite("setTheme")
    @MainActor
    struct SetTheme {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.theme.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func updatesCurrent() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let client = ThemeClient()
            #expect(client.current == .light)
            client.setTheme(.dark)
            #expect(client.current == .dark)
        }

        @Test func persistsToUserDefaults() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let client = ThemeClient()
            client.setTheme(.dark)
            UserDefaultsClient.defaults = defaults
            let saved = UserDefaultsClient.get(AppTheme.self, for: .appTheme)
            #expect(saved == .dark)
        }

        @Test func toggleBackToLight() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let client = ThemeClient()
            client.setTheme(.dark)
            client.setTheme(.light)
            #expect(client.current == .light)
            UserDefaultsClient.defaults = defaults
            #expect(UserDefaultsClient.get(AppTheme.self, for: .appTheme) == .light)
        }
    }
}
