import Testing
import Foundation
@testable import Talk

@Suite("MigrationClient", .serialized)
@MainActor
struct MigrationClientTests {

    @Suite("Guard / idempotency")
    @MainActor
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
            UserDefaultsClient.defaults = defaults
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
    @MainActor
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
            UserDefaultsClient.defaults = defaults
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
            #expect(liked.contains("q1"))
            #expect(liked.contains("q2"))
        }

        @Test func emptyFavoritesLeavesLikedUnchanged() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set([String](), forKey: "favorites")
            MigrationClient.runIfNeeded()
            UserDefaultsClient.defaults = defaults
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions)
            #expect(liked == nil || liked!.isEmpty)
        }

        @Test func mergesWithExistingLikedQuestions() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["q2"], for: .likedQuestions)
            defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            UserDefaultsClient.defaults = defaults
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
            UserDefaultsClient.defaults = defaults
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

    @Suite("migratePremiumFlagToAppGroup")
    @MainActor
    struct MigratePremiumFlag {
        let defaults: UserDefaults
        let groupDefaults: UserDefaults
        let suite: String
        let groupSuite: String

        init() {
            suite = "com.talk.tests.migration.\(UUID().uuidString)"
            groupSuite = "com.talk.tests.migration.group.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
            groupDefaults = UserDefaults(suiteName: groupSuite)!
        }

        @Test func legacyTrue_movedToAppGroup() throws {
            UserDefaultsClient.defaults = defaults
            MigrationClient.appGroupDefaults = groupDefaults
            defer {
                UserDefaults.standard.removePersistentDomain(forName: suite)
                UserDefaults.standard.removePersistentDomain(forName: groupSuite)
            }
            defaults.set(try JSONEncoder().encode(true), forKey: "isPremium")
            MigrationClient.runIfNeeded()
            #expect(groupDefaults.bool(forKey: AppGroupKey.isPremium) == true)
        }

        @Test func legacyKeyRemovedAfterMigration() throws {
            UserDefaultsClient.defaults = defaults
            MigrationClient.appGroupDefaults = groupDefaults
            defer {
                UserDefaults.standard.removePersistentDomain(forName: suite)
                UserDefaults.standard.removePersistentDomain(forName: groupSuite)
            }
            defaults.set(try JSONEncoder().encode(true), forKey: "isPremium")
            MigrationClient.runIfNeeded()
            #expect(defaults.object(forKey: "isPremium") == nil)
        }

        @Test func existingAppGroupValueNotOverwritten() throws {
            UserDefaultsClient.defaults = defaults
            MigrationClient.appGroupDefaults = groupDefaults
            defer {
                UserDefaults.standard.removePersistentDomain(forName: suite)
                UserDefaults.standard.removePersistentDomain(forName: groupSuite)
            }
            groupDefaults.set(false, forKey: AppGroupKey.isPremium)
            defaults.set(try JSONEncoder().encode(true), forKey: "isPremium")
            MigrationClient.runIfNeeded()
            #expect(groupDefaults.bool(forKey: AppGroupKey.isPremium) == false)
            #expect(defaults.object(forKey: "isPremium") == nil)
        }

        @Test func noLegacyKey_appGroupUntouched() {
            UserDefaultsClient.defaults = defaults
            MigrationClient.appGroupDefaults = groupDefaults
            defer {
                UserDefaults.standard.removePersistentDomain(forName: suite)
                UserDefaults.standard.removePersistentDomain(forName: groupSuite)
            }
            MigrationClient.runIfNeeded()
            #expect(groupDefaults.object(forKey: AppGroupKey.isPremium) == nil)
        }

        @Test func runsEvenWhenStorageMigrationFlagAlreadySet() throws {
            UserDefaultsClient.defaults = defaults
            MigrationClient.appGroupDefaults = groupDefaults
            defer {
                UserDefaults.standard.removePersistentDomain(forName: suite)
                UserDefaults.standard.removePersistentDomain(forName: groupSuite)
            }
            UserDefaultsClient.set(true, for: .didMigrateFromStorageClient)
            defaults.set(try JSONEncoder().encode(true), forKey: "isPremium")
            MigrationClient.runIfNeeded()
            #expect(groupDefaults.bool(forKey: AppGroupKey.isPremium) == true)
        }
    }

    @Suite("migrateSubcategoryProgress")
    @MainActor
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
            UserDefaultsClient.defaults = defaults
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
            UserDefaultsClient.defaults = defaults
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["couple"] == 10)
        }

        @Test func multipleLegacyKeysMigratedAtOnce() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set(3, forKey: "lastQuestionIndex_couple")
            defaults.set(7, forKey: "lastQuestionIndex_family")
            MigrationClient.runIfNeeded()
            UserDefaultsClient.defaults = defaults
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["couple"] == 3)
            #expect(progress?["family"] == 7)
        }

        @Test func noLegacyKeysLeavesProgressAbsent() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            MigrationClient.runIfNeeded()
            UserDefaultsClient.defaults = defaults
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress == nil || progress!.isEmpty)
        }
    }
}
