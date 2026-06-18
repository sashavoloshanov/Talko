import Foundation
 
struct Badge: Identifiable {
    let id: String
    let subcategoryId: String
    let subcategoryName: String
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
