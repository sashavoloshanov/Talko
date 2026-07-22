import Foundation

struct Badge: Identifiable {
    let id: String
    let categoryId: String
    let categoryName: String
    let tier: Int
    let threshold: Int
    let progress: Int
    let isEarned: Bool
    let imageName: String
    let name: String
}

extension Badge: Hashable {
    static func == (lhs: Badge, rhs: Badge) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
