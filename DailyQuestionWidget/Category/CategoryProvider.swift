import WidgetKit
import Foundation

struct CategoryProvider: TimelineProvider {
    let categoryId: String

    func placeholder(in context: Context) -> CategoryEntry {
        CategoryEntry(date: .now, questionText: WidgetFallback.placeholderCategoryQuestion,
                      categoryId: categoryId, categoryName: "...", categoryEmoji: "",
                      currentIndex: 1, totalCount: 50)
    }

    func getSnapshot(in context: Context, completion: @escaping (CategoryEntry) -> Void) {
        completion(makeEntry(defaults: UserDefaults(suiteName: AppGroupKey.suiteName)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CategoryEntry>) -> Void) {
        completion(Timeline(entries: [makeEntry(defaults: UserDefaults(suiteName: AppGroupKey.suiteName))], policy: .never))
    }

    func makeEntry(defaults: UserDefaults?) -> CategoryEntry {
        let payload = loadPayload(from: defaults)
        let questions = payload?.questions ?? []
        let rawIndex = defaults?.integer(forKey: AppGroupKey.widgetIndex(categoryId: categoryId)) ?? 0
        let safeIndex = questions.isEmpty ? 0 : rawIndex % questions.count

        return CategoryEntry(
            date: .now,
            questionText: questions.isEmpty
                ? WidgetFallback.reload
                : questions[safeIndex],
            categoryId:    categoryId,
            categoryName:  payload?.name ?? categoryId,
            categoryEmoji: payload?.emoji ?? "",
            currentIndex:  safeIndex + 1,
            totalCount:    max(questions.count, 1)
        )
    }

    func loadPayload(from defaults: UserDefaults?) -> WidgetCategoryPayload? {
        guard let data = defaults?.data(forKey: AppGroupKey.widgetCategory(categoryId: categoryId)) else { return nil }
        return try? JSONDecoder().decode(WidgetCategoryPayload.self, from: data)
    }
}
