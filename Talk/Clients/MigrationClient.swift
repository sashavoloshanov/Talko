import Foundation

struct MigrationClient {
    static func runIfNeeded() {
        guard UserDefaultsClient.get(Bool.self, for: .didMigrateFromStorageClient) != true else { return }
        migrateFromStorageClient()
        UserDefaultsClient.set(true, for: .didMigrateFromStorageClient)
    }

    private static func migrateFromStorageClient() {
        migrateLikedQuestions()
        migrateSubcategoryProgress()
    }

    private static func migrateLikedQuestions() {
        let defaults = UserDefaults.standard
        guard let legacyArray = defaults.stringArray(forKey: "favorites"), !legacyArray.isEmpty else { return }

        let existing = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
        let merged = Array(Set(existing + legacyArray))
        UserDefaultsClient.set(merged, for: .likedQuestions)
        defaults.removeObject(forKey: "favorites")
    }

    private static func migrateSubcategoryProgress() {
        let defaults = UserDefaults.standard
        let prefix = "lastQuestionIndex_"
        let legacyKeys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(prefix) }
        guard !legacyKeys.isEmpty else { return }

        var progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress) ?? [:]
        for key in legacyKeys {
            let categoryId = String(key.dropFirst(prefix.count))
            if progress[categoryId] == nil {
                progress[categoryId] = defaults.integer(forKey: key)
            }
            defaults.removeObject(forKey: key)
        }
        UserDefaultsClient.set(progress, for: .subcategoryProgress)
    }
}
