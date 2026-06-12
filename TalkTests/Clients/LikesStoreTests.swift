import Testing
import Foundation
@testable import Talk

@Suite("LikesStore", .serialized)
@MainActor
struct LikesStoreTests {

    @Suite("toggle")
    struct Toggle {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.likes.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test @MainActor func toggleAddsId() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            store.toggle("q1")
            #expect(store.likedIds.contains("q1"))
        }

        @Test @MainActor func toggleTwiceRemovesId() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q1")
            #expect(!store.likedIds.contains("q1"))
        }

        @Test @MainActor func toggleMultipleDifferentIds() {
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
    struct Persistence {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.likes.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test @MainActor func toggleThenReloadContainsId() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store1 = LikesStore()
            store1.toggle("q1")
            let store2 = LikesStore()
            #expect(store2.likedIds.contains("q1"))
        }

        @Test @MainActor func toggleTwiceThenReloadIsEmpty() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store1 = LikesStore()
            store1.toggle("q1")
            store1.toggle("q1")
            let store2 = LikesStore()
            #expect(store2.likedIds.isEmpty)
        }
    }

    @Suite("Initial state")
    struct InitialState {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.likes.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test @MainActor func freshStoreIsEmpty() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            #expect(store.likedIds.isEmpty)
        }
    }
}
