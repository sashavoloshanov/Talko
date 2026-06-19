import Testing
import Foundation
@testable import Talk

@Suite("LikesStore", .serialized)
@MainActor
struct LikesStoreTests {

    @Suite("toggle")
    @MainActor
    struct Toggle {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.likes.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func toggleAddsId() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            store.toggle("q1")
            #expect(store.likedIds.contains("q1"))
        }

        @Test func toggleTwiceRemovesId() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q1")
            #expect(!store.likedIds.contains("q1"))
        }

        @Test func toggleMultipleDifferentIds() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q2")
            store.toggle("q3")
            #expect(store.likedIds.contains("q1"))
            #expect(store.likedIds.contains("q2"))
            #expect(store.likedIds.contains("q3"))
        }
    }

    @Suite("Persistence")
    @MainActor
    struct Persistence {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.likes.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func toggleThenReloadContainsId() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store1 = LikesStore()
            store1.toggle("q1")
            UserDefaultsClient.defaults = defaults
            let store2 = LikesStore()
            #expect(store2.likedIds.contains("q1"))
        }

        @Test func toggleTwiceThenReloadIsEmpty() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store1 = LikesStore()
            store1.toggle("q1")
            store1.toggle("q1")
            UserDefaultsClient.defaults = defaults
            let store2 = LikesStore()
            #expect(store2.likedIds.isEmpty)
        }
    }

    @Suite("Initial state")
    @MainActor
    struct InitialState {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.likes.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func freshStoreIsEmpty() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            #expect(store.likedIds.isEmpty)
        }
    }

    @Suite("removePremiumLikes")
    @MainActor
    struct RemovePremiumLikes {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.likes.remove.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func removesLikedIdsFromPremiumSubcategories() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            store.toggle("premium-q1")
            store.toggle("free-q1")
            let premiumSub = Subcategory.fixture(id: "prem", isPremium: true, questions: [.fixture(id: "premium-q1")])
            let freeSub = Subcategory.fixture(id: "free", isPremium: false, questions: [.fixture(id: "free-q1")])
            let category = Category.fixture(subcategories: [premiumSub, freeSub])
            store.removePremiumLikes(categories: [category])
            #expect(!store.likedIds.contains("premium-q1"))
            #expect(store.likedIds.contains("free-q1"))
        }

        @Test func keepsAllLikedIdsWhenNoPremiumSubcategories() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            store.toggle("q1")
            let freeSub = Subcategory.fixture(isPremium: false, questions: [.fixture(id: "q1")])
            let category = Category.fixture(subcategories: [freeSub])
            store.removePremiumLikes(categories: [category])
            #expect(store.likedIds.contains("q1"))
        }

        @Test func removesLikedIdsAcrossMultipleCategories() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            store.toggle("pq1")
            store.toggle("pq2")
            store.toggle("fq1")
            let premSub1 = Subcategory.fixture(id: "ps1", isPremium: true, questions: [.fixture(id: "pq1")])
            let premSub2 = Subcategory.fixture(id: "ps2", isPremium: true, questions: [.fixture(id: "pq2")])
            let freeSub = Subcategory.fixture(id: "fs1", isPremium: false, questions: [.fixture(id: "fq1")])
            let cat1 = Category.fixture(id: "c1", subcategories: [premSub1])
            let cat2 = Category.fixture(id: "c2", subcategories: [premSub2, freeSub])
            store.removePremiumLikes(categories: [cat1, cat2])
            #expect(!store.likedIds.contains("pq1"))
            #expect(!store.likedIds.contains("pq2"))
            #expect(store.likedIds.contains("fq1"))
        }

        @Test func noOpWhenNothingLiked() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            let premSub = Subcategory.fixture(isPremium: true, questions: [.fixture(id: "pq1")])
            let category = Category.fixture(subcategories: [premSub])
            store.removePremiumLikes(categories: [category])
            #expect(store.likedIds.isEmpty)
        }
    }
}
