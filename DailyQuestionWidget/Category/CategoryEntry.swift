import WidgetKit

struct CategoryEntry: TimelineEntry {
    let date: Date
    let questionText: String
    let categoryId: String
    let categoryName: String
    let categoryEmoji: String
    let currentIndex: Int
    let totalCount: Int
}
