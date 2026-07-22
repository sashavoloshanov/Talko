import Foundation
import Observation

@Observable
final class BadgesViewModel: BaseViewModel {
    var badgesByCategory: [String: [Badge]] = [:]
    var categories: [Category] = []

    @ObservationIgnored private var holder: QuestionClientHolder?
    @ObservationIgnored private var languageClient: LanguageClient?

    func setup(holder: QuestionClientHolder, languageClient: LanguageClient) {
        self.holder = holder
        self.languageClient = languageClient
    }

    func load(categories: [Category]) {
        self.categories = categories
        self.badgesByCategory = BadgesClient.badges(for: categories)
        prefetchEarnedBadges()
    }

    func loadContent() async {
        guard let holder, let languageClient else { return }
        do {
            try await holder.load(language: languageClient.current)
            load(categories: holder.categories)
        } catch is CancellationError {
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reloadContent() async {
        holder?.reload()
        await loadContent()
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
