import Foundation
import WidgetKit

@Observable
final class QuestionClientHolder {
    var categories: [Category] = []
    var dailyQuestion: DailyQuestion? = nil
}

actor QuestionClient {
    static let shared = QuestionClient()

    func loadCategories(language: AppLanguage) async throws -> [Category] {
        let names = ["couple", "family", "friends"]
        let categories = try names.map { try loadCategory($0, language: language) }

        // Зберігаємо питання для віджету
        let isPremium = UserDefaults(suiteName: "group.com.talk.shared")?
            .bool(forKey: "isPremium") ?? false
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

        UserDefaults(suiteName: "group.com.talk.shared")?.set(text, forKey: "dailyQuestion")
        WidgetCenter.shared.reloadTimelines(ofKind: "DailyQuestionWidget")

        return DailyQuestion(text: text)
    }

    // MARK: - Widget sync

    private func saveQuestionsForWidget(categories: [Category], isPremium: Bool) {
        let defaults = UserDefaults(suiteName: "group.com.talk.shared")

        for category in categories {
            defaults?.set(category.name,  forKey: "widgetCategoryName_\(category.id)")
            defaults?.set(category.emoji, forKey: "widgetCategoryEmoji_\(category.id)")

            let questions: [String] = isPremium
                ? category.subcategories.flatMap { $0.questions.map(\.text) }
                : category.subcategories.filter { !$0.isPremium }.flatMap { $0.questions.map(\.text) }

            if let data = try? JSONEncoder().encode(questions) {
                defaults?.set(data, forKey: "widgetQuestions_\(category.id)")
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
