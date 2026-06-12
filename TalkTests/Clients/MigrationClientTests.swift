import Testing
import Foundation
@testable import Talk

@Suite("MigrationClient", .serialized)
struct MigrationClientTests {

    @Suite("Guard / idempotency")
    struct Idempotency {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.migration.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func afterRunIfNeededFlagIsSet() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            MigrationClient.runIfNeeded()
            let flag = UserDefaultsClient.get(Bool.self, for: .didMigrateFromStorageClient)
            #expect(flag == true)
        }

        @Test func secondRunIfNeededDoesNotMigrate() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let favoritesStillPresent = defaults.stringArray(forKey: "favorites")
            #expect(favoritesStillPresent != nil)
        }
    }

    @Suite("migrateLikedQuestions")
    struct MigrateLiked {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.migration.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func migratesFavoritesToLikedQuestions() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set(["q1", "q2"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
            #expect(liked.contains("q1"))
            #expect(liked.contains("q2"))
        }

        @Test func emptyFavoritesLeavesLikedUnchanged() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set([String](), forKey: "favorites")
            MigrationClient.runIfNeeded()
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions)
            #expect(liked == nil || liked!.isEmpty)
        }

        @Test func mergesWithExistingLikedQuestions() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["q2"], for: .likedQuestions)
            defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
            #expect(liked.contains("q1"))
            #expect(liked.contains("q2"))
        }

        @Test func mergedResultHasNoDuplicates() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["q1"], for: .likedQuestions)
            defaults.set(["q1", "q2"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
            #expect(liked.count == Set(liked).count)
        }

        @Test func favoritesKeyRemovedAfterMigration() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            #expect(defaults.stringArray(forKey: "favorites") == nil)
        }
    }

    @Suite("migrateSubcategoryProgress")
    struct MigrateProgress {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.migration.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func migratesLegacyIndexToSubcategoryProgress() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set(5, forKey: "lastQuestionIndex_couple")
            MigrationClient.runIfNeeded()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["couple"] == 5)
        }

        @Test func legacyKeyRemovedAfterMigration() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set(5, forKey: "lastQuestionIndex_couple")
            MigrationClient.runIfNeeded()
            #expect(defaults.object(forKey: "lastQuestionIndex_couple") == nil)
        }

        @Test func existingProgressNotOverwritten() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["couple": 10], for: .subcategoryProgress)
            defaults.set(5, forKey: "lastQuestionIndex_couple")
            MigrationClient.runIfNeeded()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["couple"] == 10)
        }

        @Test func multipleLegacyKeysMigratedAtOnce() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set(3, forKey: "lastQuestionIndex_couple")
            defaults.set(7, forKey: "lastQuestionIndex_family")
            MigrationClient.runIfNeeded()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["couple"] == 3)
            #expect(progress?["family"] == 7)
        }

        @Test func noLegacyKeysLeavesProgressAbsent() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            MigrationClient.runIfNeeded()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress == nil || progress!.isEmpty)
        }
    }
}
