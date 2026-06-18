import Testing
import Foundation
@testable import Talk

@Suite("UserDefaultsClient.remove", .serialized)
@MainActor
struct UserDefaultsClientRemoveTests {

    let suite: String
    let defaults: UserDefaults

    init() {
        suite = "com.talk.tests.remove.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
        UserDefaultsClient.defaults = defaults
    }

    @Test func remove_existingKey_returnsNilAfterwards() {
        UserDefaultsClient.set("hello", for: .appLanguage)
        #expect(UserDefaultsClient.get(String.self, for: .appLanguage) != nil)
        UserDefaultsClient.remove(.appLanguage)
        #expect(UserDefaultsClient.get(String.self, for: .appLanguage) == nil)
    }

    @Test func remove_nonExistingKey_doesNotCrash() {
        UserDefaultsClient.remove(.likedQuestions)
        #expect(UserDefaultsClient.get([String].self, for: .likedQuestions) == nil)
    }

    @Test func remove_doesNotAffectOtherKeys() {
        UserDefaultsClient.set(true, for: .isPremium)
        UserDefaultsClient.set("value", for: .appLanguage)
        UserDefaultsClient.remove(.appLanguage)
        #expect(UserDefaultsClient.get(Bool.self, for: .isPremium) == true)
    }

    @Test func remove_thenSet_returnsNewValue() {
        UserDefaultsClient.set("first", for: .appLanguage)
        UserDefaultsClient.remove(.appLanguage)
        UserDefaultsClient.set("second", for: .appLanguage)
        #expect(UserDefaultsClient.get(String.self, for: .appLanguage) == "second")
    }
}
