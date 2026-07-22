import Foundation
import WidgetKit

@MainActor
@Observable
final class QuestionClientHolder {
    var categories: [Category] = []
    var dailyQuestion: DailyQuestion?
    private(set) var loadedLanguage: AppLanguage?
    private(set) var isLoading: Bool = false
    private(set) var subcategoriesById: [String: Subcategory] = [:]

    private let client: any QuestionClientProtocol
    private var loadingTask: Task<Void, Error>?

    init(client: any QuestionClientProtocol = QuestionClient.shared) {
        self.client = client
    }

    func subcategory(withId id: String) -> Subcategory? {
        subcategoriesById[id]
    }

    func load(language: AppLanguage) async throws {
        guard loadedLanguage != language, !isLoading else { return }
        isLoading = true
        let task = Task {
            defer { isLoading = false }
            async let cats = client.loadCategories(language: language)
            async let daily = client.loadDailyQuestion(language: language)
            let (c, d) = try await (cats, daily)
            self.categories = c
            self.dailyQuestion = d
            self.subcategoriesById = Dictionary(
                c.flatMap(\.subcategories).map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }
            )
            self.loadedLanguage = language
        }
        loadingTask = task
        try await task.value
    }

    func reload() {
        loadingTask?.cancel()
        loadingTask = nil
        loadedLanguage = nil
        isLoading = false
    }
}

protocol QuestionClientProtocol: Actor {
    func loadCategories(language: AppLanguage) async throws -> [Category]
    func loadDailyQuestion(language: AppLanguage) async throws -> DailyQuestion
    func refreshWidgetData(for language: AppLanguage) async
}

actor QuestionClient: QuestionClientProtocol {
    static let shared = QuestionClient()

    private let contentBundle: Bundle
    private let widgetDefaults: UserDefaults?
    private let widgetCenter: any WidgetCenterProtocol

    init(
        contentBundle: Bundle = .main,
        widgetDefaults: UserDefaults? = UserDefaults(suiteName: AppGroupKey.suiteName),
        widgetCenter: any WidgetCenterProtocol = WidgetCenter.shared
    ) {
        self.contentBundle = contentBundle
        self.widgetDefaults = widgetDefaults
        self.widgetCenter = widgetCenter
    }

    func loadCategories(language: AppLanguage) async throws -> [Category] {
        let names = ["couple", "family", "friends"]
        let categories = try names.map { try loadCategory($0, language: language) }

        let isPremium = await widgetDefaults?.bool(forKey: AppGroupKey.isPremium) ?? false
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

        return DailyQuestion(text: text)
    }

    func refreshWidgetData(for language: AppLanguage) async {
        let names = ["couple", "family", "friends"]
        if let categories = try? names.map({ try loadCategory($0, language: language) }) {
            let isPremium = await widgetDefaults?.bool(forKey: AppGroupKey.isPremium) ?? false
            saveQuestionsForWidget(categories: categories, isPremium: isPremium)
        }
    }

    private func saveQuestionsForWidget(categories: [Category], isPremium: Bool) {
        for category in categories {
            widgetDefaults?.set(category.name,  forKey: AppGroupKey.widgetCategoryName(categoryId: category.id))
            widgetDefaults?.set(category.emoji, forKey: AppGroupKey.widgetCategoryEmoji(categoryId: category.id))

            let questions: [String] = isPremium
                ? category.subcategories.flatMap { $0.questions.map(\.text) }
                : category.subcategories.filter { !$0.isPremium }.flatMap { $0.questions.map(\.text) }

            if let data = try? JSONEncoder().encode(questions) {
                widgetDefaults?.set(data, forKey: AppGroupKey.widgetQuestions(categoryId: category.id))
            }
        }

        widgetCenter.reloadAllTimelines()
    }

    private func loadCategory(_ name: String, language: AppLanguage) throws -> Category {
        let url = try fileURL(name: name, language: language)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Category.self, from: data)
    }

    private func fileURL(name: String, language: AppLanguage) throws -> URL {
        let bundle = Bundle(path: contentBundle.path(forResource: language.rawValue, ofType: "lproj") ?? "") ?? contentBundle
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
