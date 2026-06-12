import Testing
@testable import Talk

private let testSuite = "com.talk.tests.migration"

@Suite("MigrationClient")
struct MigrationClientTests {

    init() {
        UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
        UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
    }

    @Suite("Guard / idempotency")
    struct Idempotency {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test func afterRunIfNeededFlagIsSet() {
            MigrationClient.runIfNeeded()
            let flag = UserDefaultsClient.get(Bool.self, for: .didMigrateFromStorageClient)
            #expect(flag == true)
        }

        @Test func secondRunIfNeededDoesNotMigrate() {
            UserDefaultsClient.defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            UserDefaultsClient.defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let favoritesStillPresent = UserDefaultsClient.defaults.stringArray(forKey: "favorites")
            #expect(favoritesStillPresent != nil)
        }
    }

    @Suite("migrateLikedQuestions")
    struct MigrateLiked {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test func migratesFavoritesToLikedQuestions() {
            UserDefaultsClient.defaults.set(["q1", "q2"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
            #expect(liked.contains("q1"))
            #expect(liked.contains("q2"))
        }

        @Test func emptyFavoritesLeavesLikedUnchanged() {
            UserDefaultsClient.defaults.set([], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions)
            #expect(liked == nil || liked!.isEmpty)
        }

        @Test func mergesWithExistingLikedQuestions() {
            UserDefaultsClient.set(["q2"], for: .likedQuestions)
            UserDefaultsClient.defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
            #expect(liked.contains("q1"))
            #expect(liked.contains("q2"))
        }

        @Test func mergedResultHasNoDuplicates() {
            UserDefaultsClient.set(["q1"], for: .likedQuestions)
            UserDefaultsClient.defaults.set(["q1", "q2"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
            #expect(liked.count == Set(liked).count)
        }

        @Test func favoritesKeyRemovedAfterMigration() {
            UserDefaultsClient.defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            #expect(UserDefaultsClient.defaults.stringArray(forKey: "favorites") == nil)
        }
    }

    @Suite("migrateSubcategoryProgress")
    struct MigrateProgress {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test func migratesLegacyIndexToSubcategoryProgress() {
            UserDefaultsClient.defaults.set(5, forKey: "lastQuestionIndex_couple")
            MigrationClient.runIfNeeded()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["couple"] == 5)
        }

        @Test func legacyKeyRemovedAfterMigration() {
            UserDefaultsClient.defaults.set(5, forKey: "lastQuestionIndex_couple")
            MigrationClient.runIfNeeded()
            #expect(UserDefaultsClient.defaults.object(forKey: "lastQuestionIndex_couple") == nil)
        }

        @Test func existingProgressNotOverwritten() {
            UserDefaultsClient.set(["couple": 10], for: .subcategoryProgress)
            UserDefaultsClient.defaults.set(5, forKey: "lastQuestionIndex_couple")
            MigrationClient.runIfNeeded()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["couple"] == 10)
        }

        @Test func multipleLegacyKeysMigratedAtOnce() {
            UserDefaultsClient.defaults.set(3, forKey: "lastQuestionIndex_couple")
            UserDefaultsClient.defaults.set(7, forKey: "lastQuestionIndex_family")
            MigrationClient.runIfNeeded()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["couple"] == 3)
            #expect(progress?["family"] == 7)
        }

        @Test func noLegacyKeysLeavesProgressAbsent() {
            MigrationClient.runIfNeeded()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress == nil || progress!.isEmpty)
        }
    }
}
