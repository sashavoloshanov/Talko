import Testing
import Foundation
@testable import Talk

@Suite("HomeViewModel", .serialized)
@MainActor
struct HomeViewModelTests {

    @Suite("isLocked")
    struct IsLocked {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.home.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test @MainActor func premiumSubNotPremiumUser_isLocked() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = HomeViewModel()
            let sub = Subcategory.fixture(isPremium: true)
            #expect(vm.isLocked(sub, isPremium: false) == true)
        }

        @Test @MainActor func premiumSubPremiumUser_notLocked() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = HomeViewModel()
            let sub = Subcategory.fixture(isPremium: true)
            #expect(vm.isLocked(sub, isPremium: true) == false)
        }

        @Test @MainActor func freeSubNotPremiumUser_notLocked() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = HomeViewModel()
            let sub = Subcategory.fixture(isPremium: false)
            #expect(vm.isLocked(sub, isPremium: false) == false)
        }

        @Test @MainActor func freeSubPremiumUser_notLocked() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = HomeViewModel()
            let sub = Subcategory.fixture(isPremium: false)
            #expect(vm.isLocked(sub, isPremium: true) == false)
        }
    }

    @Suite("hasLikedQuestions")
    struct HasLiked {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.home.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test @MainActor func emptyStoreReturnsFalse() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = HomeViewModel()
            let store = LikesStore()
            #expect(vm.hasLikedQuestions(store) == false)
        }

        @Test @MainActor func afterToggleReturnsTrue() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = HomeViewModel()
            let store = LikesStore()
            store.toggle("q1")
            #expect(vm.hasLikedQuestions(store) == true)
        }

        @Test @MainActor func afterDoubleToggleReturnsFalse() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = HomeViewModel()
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q1")
            #expect(vm.hasLikedQuestions(store) == false)
        }
    }

    @Suite("loadContent")
    struct LoadContent {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.home.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test @MainActor func successClearsErrorMessage() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = HomeViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            #expect(vm.errorMessage == nil)
        }

        @Test @MainActor func throwingSetsErrorMessage() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let mock = MockQuestionClient()
            await mock.setThrow(true)
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = HomeViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            #expect(vm.errorMessage != nil)
        }
    }

    @Suite("reloadContent")
    struct ReloadContent {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.home.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test @MainActor func reloadCallsLoadTwice() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = HomeViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            await vm.reloadContent(holder: holder, language: .english, premiumClient: premium)
            let count = await mock.loadCategoriesCallCount
            #expect(count == 2)
        }
    }
}

extension MockQuestionClient {
    func setThrow(_ value: Bool) {
        shouldThrow = value
    }
}
