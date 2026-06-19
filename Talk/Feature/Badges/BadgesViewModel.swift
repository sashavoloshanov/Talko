import Foundation
import Observation

@Observable
final class BadgesViewModel: BaseViewModel {
    var badgesByCategory: [String: [Badge]] = [:]
    var categories: [Category] = []

    func load(categories: [Category]) {
        self.categories = categories
        self.badgesByCategory = BadgesClient.badges(for: categories)
        prefetchEarnedBadges()
    }

    func loadContent(holder: QuestionClientHolder, language: AppLanguage, premiumClient: PremiumClient) async {
        do {
            try await holder.load(language: language)
            load(categories: holder.categories)
        } catch is CancellationError {
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reloadContent(holder: QuestionClientHolder, language: AppLanguage, premiumClient: PremiumClient) async {
        holder.reload()
        await loadContent(holder: holder, language: language, premiumClient: premiumClient)
    }

    private func prefetchEarnedBadges() {
        let imageNames = badgesByCategory.values
            .flatMap { $0 }
            .filter { $0.isEarned }
            .map { $0.imageName }

        Task {
            for imageName in imageNames {
                _ = try? await BadgeImageClient.shared.image(named: imageName)
            }
        }
    }
}
