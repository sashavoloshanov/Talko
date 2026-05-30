import Foundation
import Observation

@Observable
final class HomeViewModel: BaseViewModel {
    var categories: [Category] = []
    var dailyQuestion: DailyQuestion? = nil

    private var loadedLanguage: AppLanguage? = nil

    func setup(holder: QuestionClientHolder, languageClient: LanguageClient, premiumClient: PremiumClient) {
        categories = holder.categories
        dailyQuestion = holder.dailyQuestion

        let currentLang = languageClient.current
        guard loadedLanguage != currentLang else { return }

        Task {
            await loadData(holder: holder, language: currentLang, premiumClient: premiumClient)
        }
    }

    func reload(holder: QuestionClientHolder, language: AppLanguage, premiumClient: PremiumClient) {
        Task {
            await loadData(holder: holder, language: language, premiumClient: premiumClient)
        }
    }

    private func loadData(holder: QuestionClientHolder, language: AppLanguage, premiumClient: PremiumClient) async {
        do {
            async let categories = QuestionClient.shared.loadCategories(language: language)
            async let daily = QuestionClient.shared.loadDailyQuestion(language: language)
            async let premium: () = premiumClient.checkPremiumStatus()

            let (cats, dailyQ, _) = try await (categories, daily, premium)

            await MainActor.run {
                holder.categories = cats
                holder.dailyQuestion = dailyQ
                self.categories = cats
                self.dailyQuestion = dailyQ
                self.loadedLanguage = language
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
