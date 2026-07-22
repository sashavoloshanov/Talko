import Foundation

enum AppGroupKey {
    static let suiteName = "group.com.voloshanov.talk.shared"
    static let isPremium = "isPremium"
    static let appLanguage = "appLanguage"

    static func widgetCategory(categoryId: String) -> String { "widgetCategory_\(categoryId)" }
    static func widgetIndex(categoryId: String) -> String { "widgetIndex_\(categoryId)" }
}
