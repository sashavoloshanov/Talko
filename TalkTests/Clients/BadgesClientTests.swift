import Testing
import Foundation
@testable import Talk

@Suite("BadgesClient", .serialized)
@MainActor
struct BadgesClientTests {

    @Suite("earned / locked by category progress")
    @MainActor
    struct EarnedLocked {
        let category: Talk.Category = .fixture(id: "cat1", subcategories: [.fixture(id: "sub1")])

        private func badges(progress: Int) -> [Badge] {
            BadgesClient.badges(for: [category], progress: ["sub1": progress], isPremium: false)["cat1"] ?? []
        }

        @Test func progress0AllLocked() {
            let result = badges(progress: 0)
            #expect(result.filter { !$0.isEarned }.count == 3)
            #expect(result.filter { $0.isEarned }.count == 0)
        }

        @Test func progress9AllLocked() {
            let result = badges(progress: 9)
            #expect(result.filter { !$0.isEarned }.count == 3)
        }

        @Test func progress10OneEarned() {
            let result = badges(progress: 10)
            #expect(result.filter { $0.isEarned }.count == 1)
            #expect(result.filter { !$0.isEarned }.count == 2)
        }

        @Test func progress29OneEarned() {
            let result = badges(progress: 29)
            #expect(result.filter { $0.isEarned }.count == 1)
        }

        @Test func progress30TwoEarned() {
            let result = badges(progress: 30)
            #expect(result.filter { $0.isEarned }.count == 2)
        }

        @Test func progress50AllEarned() {
            let result = badges(progress: 50)
            #expect(result.filter { $0.isEarned }.count == 3)
        }
    }

    @Suite("progress is summed across subcategories")
    @MainActor
    struct SummedProgress {
        let category: Talk.Category = .fixture(id: "cat1", subcategories: [
            .fixture(id: "sub1"), .fixture(id: "sub2"), .fixture(id: "sub3")
        ])

        @Test func sumOfSubcategoriesUnlocksBadge() {
            let progress = ["sub1": 4, "sub2": 3, "sub3": 3]
            let badges = BadgesClient.badges(for: [category], progress: progress, isPremium: false)["cat1"] ?? []
            #expect(badges.first { $0.tier == 1 }?.isEarned == true)
            #expect(badges.allSatisfy { $0.progress == 10 })
        }

        @Test func progressBelowThresholdStaysLocked() {
            let progress = ["sub1": 4, "sub2": 3]
            let badges = BadgesClient.badges(for: [category], progress: progress, isPremium: false)["cat1"] ?? []
            #expect(badges.allSatisfy { !$0.isEarned })
            #expect(badges.allSatisfy { $0.progress == 7 })
        }

        @Test func unknownSubcategoryProgressIsIgnored() {
            let progress = ["other_sub": 100]
            let badges = BadgesClient.badges(for: [category], progress: progress, isPremium: false)["cat1"] ?? []
            #expect(badges.allSatisfy { !$0.isEarned })
        }
    }

    @Suite("premium subcategories")
    @MainActor
    struct PremiumFiltering {
        let category: Talk.Category = .fixture(id: "cat1", subcategories: [
            .fixture(id: "free_sub", isPremium: false),
            .fixture(id: "prem_sub", isPremium: true)
        ])

        @Test func freeUser_premiumProgressNotCounted() {
            let progress = ["free_sub": 5, "prem_sub": 20]
            let badges = BadgesClient.badges(for: [category], progress: progress, isPremium: false)["cat1"] ?? []
            #expect(badges.allSatisfy { $0.progress == 5 })
            #expect(badges.allSatisfy { !$0.isEarned })
        }

        @Test func premiumUser_premiumProgressCounted() {
            let progress = ["free_sub": 5, "prem_sub": 20]
            let badges = BadgesClient.badges(for: [category], progress: progress, isPremium: true)["cat1"] ?? []
            #expect(badges.allSatisfy { $0.progress == 25 })
            #expect(badges.first { $0.tier == 1 }?.isEarned == true)
        }
    }

    @Suite("imageName")
    @MainActor
    struct ImageName {
        let category: Talk.Category = .fixture(id: "couple", subcategories: [.fixture(id: "sub1")])

        @Test func earnedImageNameUsesCategoryAndTier() {
            let badges = BadgesClient.badges(for: [category], progress: ["sub1": 10], isPremium: false)["couple"] ?? []
            let earned = badges.first(where: { $0.isEarned })
            #expect(earned?.imageName == "badge_couple_1")
        }

        @Test func allEarnedImageNames() {
            let badges = BadgesClient.badges(for: [category], progress: ["sub1": 50], isPremium: false)["couple"] ?? []
            #expect(badges.map(\.imageName) == ["badge_couple_1", "badge_couple_2", "badge_couple_3"])
        }

        @Test func lockedImageName() {
            let badges = BadgesClient.badges(for: [category], progress: [:], isPremium: false)["couple"] ?? []
            #expect(badges.allSatisfy { $0.imageName == "lockedBadgeIcon" })
        }
    }

    @Suite("badge fields")
    @MainActor
    struct BadgeFields {
        let category: Talk.Category = .fixture(id: "couple", name: "Couple", subcategories: [.fixture(id: "sub1")])

        @Test func badgeIdsMatchFormat() {
            let badges = BadgesClient.badges(for: [category], progress: [:], isPremium: false)["couple"] ?? []
            #expect(badges.map(\.id) == ["couple_1", "couple_2", "couple_3"])
        }

        @Test func thresholdsAre10_30_50() {
            let badges = BadgesClient.badges(for: [category], progress: [:], isPremium: false)["couple"] ?? []
            #expect(badges.map(\.threshold) == [10, 30, 50])
        }

        @Test func tiersAre1_2_3() {
            let badges = BadgesClient.badges(for: [category], progress: [:], isPremium: false)["couple"] ?? []
            #expect(badges.map(\.tier) == [1, 2, 3])
        }

        @Test func categoryFieldsMatchCategory() {
            let badges = BadgesClient.badges(for: [category], progress: [:], isPremium: false)["couple"] ?? []
            #expect(badges.allSatisfy { $0.categoryId == "couple" })
            #expect(badges.allSatisfy { $0.categoryName == "Couple" })
            #expect(badges.allSatisfy { $0.name == "Couple" })
        }
    }

    @Suite("result structure")
    @MainActor
    struct ResultStructure {
        @Test func emptyCategoriesReturnsEmptyDict() {
            let result = BadgesClient.badges(for: [], progress: [:], isPremium: false)
            #expect(result.isEmpty)
        }

        @Test func categoryAlwaysHasExactly3Badges() {
            let one = Talk.Category.fixture(id: "cat1", subcategories: [.fixture(id: "sub1")])
            let many = Talk.Category.fixture(id: "cat2", subcategories: [
                .fixture(id: "s1"), .fixture(id: "s2"), .fixture(id: "s3"), .fixture(id: "s4")
            ])
            let result = BadgesClient.badges(for: [one, many], progress: [:], isPremium: false)
            #expect(result["cat1"]?.count == 3)
            #expect(result["cat2"]?.count == 3)
        }

        @Test func threeCategoriesHave3Keys() {
            let cats = [
                Talk.Category.fixture(id: "cat1"),
                Talk.Category.fixture(id: "cat2"),
                Talk.Category.fixture(id: "cat3")
            ]
            let result = BadgesClient.badges(for: cats, progress: [:], isPremium: false)
            #expect(result.keys.count == 3)
        }
    }

    @Suite("badges(for:isPremium:) — reads UserDefaults progress")
    @MainActor
    struct WithUserDefaults {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.badgesclient.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func noProgressInDefaults_allLocked() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let cat = Talk.Category.fixture(id: "cat1", subcategories: [.fixture(id: "sub1")])
            let result = BadgesClient.badges(for: [cat], isPremium: false)
            #expect(result["cat1"]?.allSatisfy { !$0.isEarned } == true)
        }

        @Test func progressInDefaults_badgesReflectProgress() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["sub1": 10], for: .subcategoryProgress)
            UserDefaultsClient.defaults = defaults
            let cat = Talk.Category.fixture(id: "cat1", subcategories: [.fixture(id: "sub1")])
            let result = BadgesClient.badges(for: [cat], isPremium: false)
            #expect(result["cat1"]?.first { $0.tier == 1 }?.isEarned == true)
        }

        @Test func progressFor50_allEarned() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["sub1": 50], for: .subcategoryProgress)
            UserDefaultsClient.defaults = defaults
            let cat = Talk.Category.fixture(id: "cat1", subcategories: [.fixture(id: "sub1")])
            let result = BadgesClient.badges(for: [cat], isPremium: false)
            #expect(result["cat1"]?.allSatisfy { $0.isEarned } == true)
        }
    }
}
