import Foundation

enum AppGroupKey {
    static let suiteName = "group.com.talk.shared"
    static let dailyQuestion = "dailyQuestion"
    static let isPremium = "isPremium"
    static let appLanguage = "appLanguage"

    static func widgetQuestions(categoryId: String) -> String { "widgetQuestions_\(categoryId)" }
    static func widgetCategoryName(categoryId: String) -> String { "widgetCategoryName_\(categoryId)" }
    static func widgetCategoryEmoji(categoryId: String) -> String { "widgetCategoryEmoji_\(categoryId)" }
    static func widgetIndex(categoryId: String) -> String { "widgetIndex_\(categoryId)" }
}
