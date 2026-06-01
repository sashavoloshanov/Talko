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

    func loadContent(holder: QuestionClientHolder, language: AppLanguage, premiumClient: PremiumClient) async {
        do {
            try await holder.load(language: language, premiumClient: premiumClient)
            load(categories: holder.categories)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reloadContent(holder: QuestionClientHolder, language: AppLanguage, premiumClient: PremiumClient) async {
        holder.reload()
        await loadContent(holder: holder, language: language, premiumClient: premiumClient)
    }
}
