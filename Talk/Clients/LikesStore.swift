import Foundation
import Observation

@Observable
final class LikesStore {
    static let shared = LikesStore()

    private(set) var likedIds: Set<String>

    private init() {
        let saved = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
        likedIds = Set(saved)
    }

    func toggle(_ id: String) {
        if likedIds.contains(id) {
            likedIds.remove(id)
        } else {
            likedIds.insert(id)
        }
        UserDefaultsClient.set(Array(likedIds), for: .likedQuestions)
    }
}
