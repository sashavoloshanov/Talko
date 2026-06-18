import Testing
import Foundation
@testable import Talk

@Suite("BadgesClient", .serialized)
@MainActor
struct BadgesClientTests {

    private let subcategoryId = "couple"
    private var category: Talk.Category {
        .fixture(id: "cat1", subcategories: [.fixture(id: subcategoryId)])
    }

    @Suite("earned / locked by progress")
    @MainActor
    struct EarnedLocked {
        let subId = "couple"
        let category: Talk.Category = .fixture(id: "cat1", subcategories: [.fixture(id: "couple")])

        private func badges(progress: Int) -> [Badge] {
            BadgesClient.badges(for: [category], progress: [subId: progress])["cat1"] ?? []
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
            #expect(result.filter { !$0.isEarned }.count == 2)
        }

        @Test func progress30TwoEarned() {
            let result = badges(progress: 30)
            #expect(result.filter { $0.isEarned }.count == 2)
            #expect(result.filter { !$0.isEarned }.count == 1)
        }

        @Test func progress50AllEarned() {
            let result = badges(progress: 50)
            #expect(result.filter { $0.isEarned }.count == 3)
        }

        @Test func progress99AllEarned() {
            let result = badges(progress: 99)
            #expect(result.filter { $0.isEarned }.count == 3)
        }
    }

    @Suite("imageName")
    @MainActor
    struct ImageName {
        let subId = "couple"
        let category: Talk.Category = .fixture(id: "cat1", subcategories: [.fixture(id: "couple")])

        @Test func earnedImageName() {
            let badges = BadgesClient.badges(for: [category], progress: [subId: 10])["cat1"] ?? []
            let earned = badges.first(where: { $0.isEarned })
            #expect(earned?.imageName == "badge_couple_10")
        }

        @Test func lockedImageName() {
            let badges = BadgesClient.badges(for: [category], progress: [subId: 0])["cat1"] ?? []
            #expect(badges.allSatisfy { $0.imageName == "lockedBadgeIcon" })
        }
    }

    @Suite("badge.id")
    @MainActor
    struct BadgeId {
        let subId = "couple"
        let category: Talk.Category = .fixture(id: "cat1", subcategories: [.fixture(id: "couple")])

        @Test func badgeIdsMatchFormat() {
            let badges = BadgesClient.badges(for: [category], progress: [:])["cat1"] ?? []
            let ids = badges.map { $0.id }
            #expect(ids.contains("couple_10"))
            #expect(ids.contains("couple_30"))
            #expect(ids.contains("couple_50"))
        }
    }

    @Suite("result structure")
    @MainActor
    struct ResultStructure {
        @Test func emptyCategoriesReturnsEmptyDict() {
            let result = BadgesClient.badges(for: [], progress: [:])
            #expect(result.isEmpty)
        }

        @Test func oneCategoryOneSubcategoryHas3Badges() {
            let cat = Talk.Category.fixture(id: "cat1", subcategories: [.fixture(id: "sub1")])
            let result = BadgesClient.badges(for: [cat], progress: [:])
            #expect(result["cat1"]?.count == 3)
        }

        @Test func oneCategoryTwoSubcategoriesHas6Badges() {
            let cat = Talk.Category.fixture(id: "cat1", subcategories: [.fixture(id: "sub1"), .fixture(id: "sub2")])
            let result = BadgesClient.badges(for: [cat], progress: [:])
            #expect(result["cat1"]?.count == 6)
        }

        @Test func threeCategoriesHave3Keys() {
            let cats = [
                Talk.Category.fixture(id: "cat1"),
                Talk.Category.fixture(id: "cat2"),
                Talk.Category.fixture(id: "cat3")
            ]
            let result = BadgesClient.badges(for: cats, progress: [:])
            #expect(result.keys.count == 3)
        }
    }

    @Suite("badges(for:) — reads UserDefaults progress")
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
            let sub = Subcategory.fixture(id: "sub1")
            let cat = Talk.Category.fixture(id: "cat1", subcategories: [sub])
            let result = BadgesClient.badges(for: [cat])
            #expect(result["cat1"]?.allSatisfy { !$0.isEarned } == true)
        }

        @Test func progressInDefaults_badgesReflectProgress() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["sub1": 10], for: .subcategoryProgress)
            UserDefaultsClient.defaults = defaults
            let sub = Subcategory.fixture(id: "sub1")
            let cat = Talk.Category.fixture(id: "cat1", subcategories: [sub])
            let result = BadgesClient.badges(for: [cat])
            let badge10 = result["cat1"]?.first { $0.id == "sub1_10" }
            #expect(badge10?.isEarned == true)
        }

        @Test func progressFor50_allEarned() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["sub1": 50], for: .subcategoryProgress)
            UserDefaultsClient.defaults = defaults
            let sub = Subcategory.fixture(id: "sub1")
            let cat = Talk.Category.fixture(id: "cat1", subcategories: [sub])
            let result = BadgesClient.badges(for: [cat])
            #expect(result["cat1"]?.allSatisfy { $0.isEarned } == true)
        }
    }

    @Suite("badge fields")
    @MainActor
    struct BadgeFields {
        let subId = "know_me"
        let subName = "Know Me"

        private var category: Talk.Category {
            .fixture(id: "cat1", subcategories: [.fixture(id: subId, name: subName)])
        }

        @Test func subcategoryIdMatchesSubcategory() {
            let badges = BadgesClient.badges(for: [category], progress: [:])["cat1"] ?? []
            #expect(badges.allSatisfy { $0.subcategoryId == subId })
        }

        @Test func subcategoryNameMatchesSubcategory() {
            let badges = BadgesClient.badges(for: [category], progress: [:])["cat1"] ?? []
            #expect(badges.allSatisfy { $0.subcategoryName == subName })
        }

        @Test func nameMatchesSubcategoryName() {
            let badges = BadgesClient.badges(for: [category], progress: [:])["cat1"] ?? []
            #expect(badges.allSatisfy { $0.name == subName })
        }

        @Test func mixedProgressAcrossSubcategoriesIsIndependent() {
            let sub1 = Subcategory.fixture(id: "sub1")
            let sub2 = Subcategory.fixture(id: "sub2")
            let cat = Talk.Category.fixture(id: "cat1", subcategories: [sub1, sub2])
            let badges = BadgesClient.badges(for: [cat], progress: ["sub1": 30, "sub2": 9])["cat1"] ?? []
            let sub1Earned = badges.filter { $0.subcategoryId == "sub1" && $0.isEarned }
            let sub2Earned = badges.filter { $0.subcategoryId == "sub2" && $0.isEarned }
            #expect(sub1Earned.count == 2)
            #expect(sub2Earned.count == 0)
        }

        @Test func earnedBadgeHasRemoteImageName() {
            let badges = BadgesClient.badges(for: [category], progress: [subId: 10])["cat1"] ?? []
            let earned = badges.filter { $0.isEarned }
            #expect(earned.allSatisfy { $0.imageName.hasPrefix("badge_") })
        }

        @Test func lockedBadgeHasLockedBadgeIconName() {
            let badges = BadgesClient.badges(for: [category], progress: [:])["cat1"] ?? []
            #expect(badges.allSatisfy { $0.imageName == "lockedBadgeIcon" })
        }
    }
}
