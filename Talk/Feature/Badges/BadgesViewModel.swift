import Foundation
import Observation

@Observable
final class BadgesViewModel: BaseViewModel {
    var badgesByCategory: [String: [Badge]] = [:]
    var categories: [Category] = []

    private var loadedLanguage: AppLanguage? = nil

    func setup(holder: QuestionClientHolder, languageClient: LanguageClient) {
        let currentLang = languageClient.current

        if loadedLanguage != currentLang {
            Task {
                await loadData(holder: holder, language: currentLang)
            }
        } else if categories.isEmpty {
            load(categories: holder.categories)
        }
    }

    func reload(holder: QuestionClientHolder, language: AppLanguage) {
        Task {
            await loadData(holder: holder, language: language)
        }
    }

    private func loadData(holder: QuestionClientHolder, language: AppLanguage) async {
        do {
            let cats = try await QuestionClient.shared.loadCategories(language: language)
            await MainActor.run {
                holder.categories = cats
                self.load(categories: cats)
                self.loadedLanguage = language
            }
        } catch {}
    }

    func load(categories: [Category]) {
        self.categories = categories
        self.badgesByCategory = BadgesClient.badges(for: categories)
    }
}
