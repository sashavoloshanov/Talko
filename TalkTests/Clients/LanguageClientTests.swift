import Testing
import Foundation
@testable import Talk

@Suite("LanguageClient", .serialized)
@MainActor
struct LanguageClientTests {

    @Suite("AppLanguage")
    @MainActor
    struct AppLanguageEnum {
        @Test func rawValues() {
            #expect(AppLanguage.ukrainian.rawValue == "uk")
            #expect(AppLanguage.english.rawValue == "en")
        }

        @Test func displayNames() {
            #expect(AppLanguage.ukrainian.displayName == "Українська")
            #expect(AppLanguage.english.displayName == "English")
        }

        @Test func idEqualsRawValue() {
            for lang in AppLanguage.allCases {
                #expect(lang.id == lang.rawValue)
            }
        }

        @Test func allCasesCount() {
            #expect(AppLanguage.allCases.count == 2)
        }
    }

    @Suite("init")
    @MainActor
    struct Init {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.language.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func noSavedLanguage_defaultsToUkrainian() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let client = LanguageClient()
            #expect(client.current == .ukrainian)
        }

        @Test func savedEnglish_restoresEnglish() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(AppLanguage.english, for: .appLanguage)
            UserDefaultsClient.defaults = defaults
            let client = LanguageClient()
            #expect(client.current == .english)
        }

        @Test func savedUkrainian_restoresUkrainian() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(AppLanguage.ukrainian, for: .appLanguage)
            UserDefaultsClient.defaults = defaults
            let client = LanguageClient()
            #expect(client.current == .ukrainian)
        }
    }

    @Suite("setLanguage")
    @MainActor
    struct SetLanguage {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.language.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func updatesCurrent() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let client = LanguageClient()
            #expect(client.current == .ukrainian)
            client.setLanguage(.english)
            #expect(client.current == .english)
        }

        @Test func persistsToUserDefaults() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let client = LanguageClient()
            client.setLanguage(.english)
            UserDefaultsClient.defaults = defaults
            let saved = UserDefaultsClient.get(AppLanguage.self, for: .appLanguage)
            #expect(saved == .english)
        }

        @Test func switchBackToUkrainian() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let client = LanguageClient()
            client.setLanguage(.english)
            client.setLanguage(.ukrainian)
            #expect(client.current == .ukrainian)
            UserDefaultsClient.defaults = defaults
            #expect(UserDefaultsClient.get(AppLanguage.self, for: .appLanguage) == .ukrainian)
        }
    }
}
