import Foundation

struct WidgetCategoryPayload: Codable {
    let name: String
    let emoji: String
    let questions: [String]
}
