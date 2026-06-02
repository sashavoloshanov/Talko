import Foundation
import WidgetKit

@MainActor
@Observable
final class QuestionClientHolder {
    var categories: [Category] = []
    var dailyQuestion: DailyQuestion?
    private(set) var loadedLanguage: AppLanguage?
    private(set) var isLoading: Bool = false

    func load(language: AppLanguage, premiumClient: PremiumClient) async throws {
        guard loadedLanguage != language, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        async let cats = QuestionClient.shared.loadCategories(language: language)
        async let daily = QuestionClient.shared.loadDailyQuestion(language: language)
        async let _: () = premiumClient.checkPremiumStatus()
        let (c, d) = try await (cats, daily)
        self.categories = c
        self.dailyQuestion = d
        self.loadedLanguage = language
    }

    func reload() {
        loadedLanguage = nil
    }
}

actor QuestionClient {
    static let shared = QuestionClient()

    func loadCategories(language: AppLanguage) async throws -> [Category] {
        let names = ["couple", "family", "friends"]
        let categories = try names.map { try loadCategory($0, language: language) }

        let isPremium = UserDefaults(suiteName: AppGroupKey.suiteName)?
            .bool(forKey: AppGroupKey.isPremium) ?? false
        saveQuestionsForWidget(categories: categories, isPremium: isPremium)

        return categories
    }

    func loadDailyQuestion(language: AppLanguage) async throws -> DailyQuestion {
        let url = try fileURL(name: "daily", language: language)
        let data = try Data(contentsOf: url)
        let payload = try JSONDecoder().decode(DailyQuestionsPayload.self, from: data)

        guard !payload.questions.isEmpty else {
            throw QuestionClientError.emptyDailyQuestions
        }

        let today = Date()
        let text = await payload.holidayQuestion(for: today) ?? payload.question(for: today)

        UserDefaults(suiteName: AppGroupKey.suiteName)?.set(text, forKey: AppGroupKey.dailyQuestion)
        WidgetCenter.shared.reloadTimelines(ofKind: "DailyQuestionWidget")

        return DailyQuestion(text: text)
    }

    func refreshWidgetData(for language: AppLanguage) async {
        let names = ["couple", "family", "friends"]
        if let categories = try? names.map({ try loadCategory($0, language: language) }) {
            let isPremium = UserDefaults(suiteName: AppGroupKey.suiteName)?.bool(forKey: AppGroupKey.isPremium) ?? false
            saveQuestionsForWidget(categories: categories, isPremium: isPremium)
        }

        if let url = try? fileURL(name: "daily", language: language),
           let data = try? Data(contentsOf: url),
           let payload = try? JSONDecoder().decode(DailyQuestionsPayload.self, from: data) {
            let text = payload.holidayQuestion(for: .now) ?? payload.question(for: .now)
            UserDefaults(suiteName: AppGroupKey.suiteName)?.set(text, forKey: AppGroupKey.dailyQuestion)
        }
    }

    private func saveQuestionsForWidget(categories: [Category], isPremium: Bool) {
        let defaults = UserDefaults(suiteName: AppGroupKey.suiteName)

        for category in categories {
            defaults?.set(category.name,  forKey: AppGroupKey.widgetCategoryName(categoryId: category.id))
            defaults?.set(category.emoji, forKey: AppGroupKey.widgetCategoryEmoji(categoryId: category.id))

            let questions: [String] = isPremium
                ? category.subcategories.flatMap { $0.questions.map(\.text) }
                : category.subcategories.filter { !$0.isPremium }.flatMap { $0.questions.map(\.text) }

            if let data = try? JSONEncoder().encode(questions) {
                defaults?.set(data, forKey: AppGroupKey.widgetQuestions(categoryId: category.id))
            }
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Private

    private func loadCategory(_ name: String, language: AppLanguage) throws -> Category {
        let url = try fileURL(name: name, language: language)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Category.self, from: data)
    }

    private func fileURL(name: String, language: AppLanguage) throws -> URL {
        let bundle = Bundle(path: Bundle.main.path(forResource: language.rawValue, ofType: "lproj") ?? "") ?? .main
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw QuestionClientError.fileNotFound(name)
        }
        return url
    }
}

enum QuestionClientError: LocalizedError {
    case fileNotFound(String)
    case emptyDailyQuestions

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name): return "File not found: \(name)"
        case .emptyDailyQuestions:   return "daily.json contains no questions"
        }
    }
}
