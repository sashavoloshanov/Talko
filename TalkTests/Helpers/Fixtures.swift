import Foundation
@testable import Talk

extension CardQuestion {
    static func fixture(id: String = "q1", text: String = "Question?") -> CardQuestion {
        CardQuestion(id: id, text: text)
    }
}

extension Subcategory {
    static func fixture(
        id: String = "sub1",
        emoji: String = "💬",
        name: String = "Sub",
        description: String = "Desc",
        isPremium: Bool = false,
        questions: [CardQuestion] = [.fixture()]
    ) -> Subcategory {
        Subcategory(id: id, emoji: emoji, name: name, description: description, isPremium: isPremium, questions: questions)
    }
}

extension Badge {
    static func fixture(
        id: String = "cat1_1",
        categoryId: String = "cat1",
        categoryName: String = "Category",
        tier: Int = 1,
        threshold: Int = 10,
        progress: Int = 0,
        isEarned: Bool = true,
        imageName: String = "badge_cat1_1",
        name: String = "Category"
    ) -> Badge {
        Badge(id: id, categoryId: categoryId, categoryName: categoryName, tier: tier, threshold: threshold,
              progress: progress, isEarned: isEarned, imageName: imageName, name: name)
    }
}

extension Talk.Category {
    static func fixture(
        id: String = "cat1",
        name: String = "Category",
        emoji: String = "🗂",
        subcategories: [Talk.Subcategory] = [.fixture()]
    ) -> Talk.Category {
        Talk.Category(id: id, name: name, emoji: emoji, subcategories: subcategories)
    }
}
