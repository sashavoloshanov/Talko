import WidgetKit
import Foundation

struct CategoryProvider: TimelineProvider {
    let categoryId: String

    func placeholder(in context: Context) -> CategoryEntry {
        CategoryEntry(date: .now, questionText: "Do you like app?",
                      categoryId: categoryId, categoryName: "...", categoryEmoji: "",
                      currentIndex: 1, totalCount: 50)
    }

    func getSnapshot(in context: Context, completion: @escaping (CategoryEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CategoryEntry>) -> Void) {
        completion(Timeline(entries: [makeEntry()], policy: .never))
    }

    // MARK: - Private
    private func makeEntry() -> CategoryEntry {
        let defaults  = UserDefaults(suiteName: AppGroupKey.suiteName)
        let questions = loadQuestions(from: defaults)
        let rawIndex  = defaults?.integer(forKey: AppGroupKey.widgetIndex(categoryId: categoryId)) ?? 0
        let safeIndex = questions.isEmpty ? 0 : rawIndex % questions.count

        return CategoryEntry(
            date: .now,
            questionText: questions.isEmpty
                ? "Reload"
                : questions[safeIndex],
            categoryId:    categoryId,
            categoryName:  defaults?.string(forKey: AppGroupKey.widgetCategoryName(categoryId: categoryId)) ?? categoryId,
            categoryEmoji: defaults?.string(forKey: AppGroupKey.widgetCategoryEmoji(categoryId: categoryId)) ?? "",
            currentIndex:  safeIndex + 1,
            totalCount:    max(questions.count, 1)
        )
    }

    private func loadQuestions(from defaults: UserDefaults?) -> [String] {
        guard
            let data = defaults?.data(forKey: AppGroupKey.widgetQuestions(categoryId: categoryId)),
            let q = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return q
    }
}
