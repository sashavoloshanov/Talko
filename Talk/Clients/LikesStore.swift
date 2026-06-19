import Foundation
import Observation

@MainActor
@Observable
final class LikesStore {
    private(set) var likedIds: Set<String>

    init() {
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

    func removePremiumLikes(categories: [Category]) {
        let premiumIds = Set(
            categories
                .flatMap(\.subcategories)
                .filter(\.isPremium)
                .flatMap { $0.questions.map(\.id) }
        )
        likedIds.subtract(premiumIds)
        UserDefaultsClient.set(Array(likedIds), for: .likedQuestions)
    }
}
