import Foundation
@testable import Talk

actor MockQuestionClient: QuestionClientProtocol {
    var stubbedCategories: [Talk.Category] = []
    var stubbedDailyQuestion = DailyQuestion(text: "Mock?")
    var shouldThrow = false
    var loadCategoriesCallCount = 0

    func loadCategories(language: AppLanguage) async throws -> [Talk.Category] {
        loadCategoriesCallCount += 1
        if shouldThrow { throw MockError.intentional }
        return stubbedCategories
    }

    func loadDailyQuestion(language: AppLanguage) async throws -> DailyQuestion {
        if shouldThrow { throw MockError.intentional }
        return stubbedDailyQuestion
    }

    func refreshWidgetData(for language: AppLanguage) async {}

    enum MockError: Error {
        case intentional
    }
}
