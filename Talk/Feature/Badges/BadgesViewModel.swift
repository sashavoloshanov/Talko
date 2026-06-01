import Foundation
import Observation

@Observable
final class BadgesViewModel: BaseViewModel {
    var badgesByCategory: [String: [Badge]] = [:]
    var categories: [Category] = []

    func load(categories: [Category]) {
        self.categories = categories
        self.badgesByCategory = BadgesClient.badges(for: categories)
    }
}
