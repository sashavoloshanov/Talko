import Foundation
 
struct BadgesClient {
    static func badges(for categories: [Category]) -> [String: [Badge]] {
        var result: [String: [Badge]] = [:]
        let thresholds = [10, 30, 50]
        let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress) ?? [:]
 
        for category in categories {
            var categoryBadges: [Badge] = []
            for sub in category.subcategories {
                let answeredCount = progress[sub.id] ?? 0
                for threshold in thresholds {
                    let isEarned = answeredCount >= threshold
                    let imageName = isEarned ? "badge_\(sub.id)_\(threshold)" : "lockedBadgeIcon"
                    let badge = Badge(
                        id: "\(sub.id)_\(threshold)",
                        subcategoryId: sub.id,
                        subcategoryName: sub.name,
                        isEarned: isEarned,
                        imageName: imageName,
                        name: "\(sub.name)"
                    )
                    categoryBadges.append(badge)
                }
            }
            result[category.id] = categoryBadges
        }
        return result
    }
}
