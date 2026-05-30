import Foundation

final class StorageClient {
    static let shared = StorageClient()
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let lastQuestionIndex = "lastQuestionIndex_"
        static let favorites = "favorites"
    }
    
    private init() {}
    
    func saveLastQuestionIndex(_ index: Int, for categoryId: String) {
        defaults.set(index, forKey: Keys.lastQuestionIndex + categoryId)
    }
    
    func lastQuestionIndex(for categoryId: String) -> Int {
        defaults.integer(forKey: Keys.lastQuestionIndex + categoryId)
    }
    
    func favorites() -> Set<String> {
        let array = defaults.stringArray(forKey: Keys.favorites) ?? []
        return Set(array)
    }
    
    func addFavorite(questionId: String) {
        var current = favorites()
        current.insert(questionId)
        defaults.set(Array(current), forKey: Keys.favorites)
    }
    
    func removeFavorite(questionId: String) {
        var current = favorites()
        current.remove(questionId)
        defaults.set(Array(current), forKey: Keys.favorites)
    }
    
    func isFavorite(questionId: String) -> Bool {
        favorites().contains(questionId)
    }
    
    func hasFavorites() -> Bool {
        !favorites().isEmpty
    }
}
