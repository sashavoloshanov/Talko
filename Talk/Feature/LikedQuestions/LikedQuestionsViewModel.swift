import Foundation
import Observation
 
@Observable
final class LikedQuestionsViewModel: BaseViewModel {
    var questions: [CardQuestion] = []
 
    func load(allCategories: [Category]) {
        let likedIds = Set(UserDefaultsClient.get([String].self, for: .likedQuestions) ?? [])
        var found: [CardQuestion] = []
        for category in allCategories {
            for sub in category.subcategories {
                for q in sub.questions where likedIds.contains(q.id) {
                    found.append(q)
                }
            }
        }
        questions = found
    }
}
