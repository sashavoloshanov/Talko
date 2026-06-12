import Testing
import Foundation
@testable import Talk

@Suite("BadgesViewModel", .serialized)
@MainActor
struct BadgesViewModelTests {

    @Suite("load")
    @MainActor
    struct Load {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.badgesvm.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func emptyCategories_badgesByCategory_isEmpty() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = BadgesViewModel()
            vm.load(categories: [])
            #expect(vm.badgesByCategory.isEmpty)
        }

        @Test func withCategories_setsCategories() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let cat = Talk.Category.fixture(id: "cat1")
            let vm = BadgesViewModel()
            vm.load(categories: [cat])
            #expect(vm.categories.count == 1)
            #expect(vm.categories.first?.id == "cat1")
        }

        @Test func withCategories_populatesBadgesByCategory() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let sub = Subcategory.fixture(id: "sub1")
            let cat = Talk.Category.fixture(id: "cat1", subcategories: [sub])
            let vm = BadgesViewModel()
            vm.load(categories: [cat])
            #expect(vm.badgesByCategory["cat1"] != nil)
            #expect(vm.badgesByCategory["cat1"]?.count == 3)
        }

        @Test func replaceCategories_updatesAll() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = BadgesViewModel()
            vm.load(categories: [Talk.Category.fixture(id: "cat1")])
            vm.load(categories: [])
            #expect(vm.categories.isEmpty)
            #expect(vm.badgesByCategory.isEmpty)
        }
    }

    @Suite("loadContent")
    @MainActor
    struct LoadContent {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.badgesvm.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func success_noErrorMessage() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = BadgesViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            UserDefaultsClient.defaults = defaults
            #expect(vm.errorMessage == nil)
        }

        @Test func success_setsCategories() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let cat = Talk.Category.fixture(id: "cat1")
            let mock = MockQuestionClient()
            await mock.setCategories([cat])
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = BadgesViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            UserDefaultsClient.defaults = defaults
            #expect(vm.categories.count == 1)
        }

        @Test func error_setsErrorMessage() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let mock = MockQuestionClient()
            await mock.setThrow(true)
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = BadgesViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            UserDefaultsClient.defaults = defaults
            #expect(vm.errorMessage != nil)
        }
    }

    @Suite("reloadContent")
    @MainActor
    struct ReloadContent {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.badgesvm.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func reloadTriggersSecondLoad() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = BadgesViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            await vm.reloadContent(holder: holder, language: .english, premiumClient: premium)
            UserDefaultsClient.defaults = defaults
            let count = await mock.loadCategoriesCallCount
            #expect(count == 2)
        }
    }
}

