import Foundation

struct BadgesClient {
    static let thresholds = [10, 30, 50, 75, 100]

    static func badges(for categories: [Category], progress: [String: Int], isPremium: Bool) -> [String: [Badge]] {
        var result: [String: [Badge]] = [:]

        for category in categories {
            let availableSubcategories = isPremium
                ? category.subcategories
                : category.subcategories.filter { !$0.isPremium }
            let answeredCount = availableSubcategories.reduce(0) { $0 + (progress[$1.id] ?? 0) }

            result[category.id] = thresholds.enumerated().map { index, threshold in
                let tier = index + 1
                let isEarned = answeredCount >= threshold
                return Badge(
                    id: "\(category.id)_\(tier)",
                    categoryId: category.id,
                    categoryName: category.name,
                    tier: tier,
                    threshold: threshold,
                    progress: answeredCount,
                    isEarned: isEarned,
                    imageName: isEarned ? "badge_\(category.id)_\(tier)" : "lockedBadgeIcon",
                    name: category.name
                )
            }
        }
        return result
    }

    static func badges(for categories: [Category], isPremium: Bool) -> [String: [Badge]] {
        let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress) ?? [:]
        return badges(for: categories, progress: progress, isPremium: isPremium)
    }
}
