import Foundation
import Observation

@Observable
final class HomeViewModel: BaseViewModel {

    func questionsForSubcategory(_ sub: Subcategory) -> [CardQuestion] {
        let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress) ?? [:]
        let lastIndex = progress[sub.id] ?? 0
        let startIndex = min(lastIndex, sub.questions.count - 1)
        return Array(sub.questions.dropFirst(startIndex)) + Array(sub.questions.prefix(startIndex))
    }

    func isLocked(_ sub: Subcategory, isPremium: Bool) -> Bool {
        sub.isPremium && !isPremium
    }

    func loadContent(holder: QuestionClientHolder, language: AppLanguage, premiumClient: PremiumClient) async {
        do {
            try await holder.load(language: language, premiumClient: premiumClient)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reloadContent(holder: QuestionClientHolder, language: AppLanguage, premiumClient: PremiumClient) async {
        holder.reload()
        await loadContent(holder: holder, language: language, premiumClient: premiumClient)
    }
}
