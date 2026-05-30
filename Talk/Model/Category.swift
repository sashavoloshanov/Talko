import Foundation
 
struct Category: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let subcategories: [Subcategory]
}
 
struct Subcategory: Identifiable, Codable, Hashable {
    let id: String
    let emoji: String
    let name: String
    let description: String
    let isPremium: Bool
    let questions: [CardQuestion]
}
