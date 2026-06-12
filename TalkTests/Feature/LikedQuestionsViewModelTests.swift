import Testing
import Foundation
@testable import Talk

@Suite("LikedQuestionsViewModel", .serialized)
@MainActor
struct LikedQuestionsViewModelTests {

    @Suite("questions(for:) before load")
    struct BeforeLoad {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.liked.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test @MainActor func emptyStoreReturnsEmpty() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = LikedQuestionsViewModel()
            let store = LikesStore()
            #expect(vm.questions(for: store).isEmpty)
        }

        @Test @MainActor func emptyCategories_returnsEmptyEvenWithLikedIds() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = LikedQuestionsViewModel()
            let store = LikesStore()
            store.toggle("q1")
            #expect(vm.questions(for: store).isEmpty)
        }
    }

    @Suite("questions(for:) after load")
    struct AfterLoad {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.liked.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test @MainActor func returnsOnlyLikedQuestions() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let q1 = CardQuestion.fixture(id: "q1")
            let q2 = CardQuestion.fixture(id: "q2")
            let cat = Talk.Category.fixture(subcategories: [.fixture(questions: [q1, q2])])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat])
            let store = LikesStore()
            store.toggle("q1")
            let result = vm.questions(for: store)
            #expect(result.count == 1)
            #expect(result[0].id == "q1")
        }

        @Test @MainActor func questionsFromMultipleSubcategories() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let q1 = CardQuestion.fixture(id: "q1")
            let q2 = CardQuestion.fixture(id: "q2")
            let cat = Talk.Category.fixture(subcategories: [
                .fixture(id: "sub1", questions: [q1]),
                .fixture(id: "sub2", questions: [q2])
            ])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat])
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q2")
            #expect(vm.questions(for: store).count == 2)
        }

        @Test @MainActor func questionsFromMultipleCategories() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let q1 = CardQuestion.fixture(id: "q1")
            let q2 = CardQuestion.fixture(id: "q2")
            let cat1 = Talk.Category.fixture(id: "cat1", subcategories: [.fixture(id: "sub1", questions: [q1])])
            let cat2 = Talk.Category.fixture(id: "cat2", subcategories: [.fixture(id: "sub2", questions: [q2])])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat1, cat2])
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q2")
            #expect(vm.questions(for: store).count == 2)
        }

        @Test @MainActor func orderFollowsCategoriesSubcategoriesQuestions() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let q1 = CardQuestion.fixture(id: "q1")
            let q2 = CardQuestion.fixture(id: "q2")
            let q3 = CardQuestion.fixture(id: "q3")
            let cat = Talk.Category.fixture(subcategories: [
                .fixture(id: "sub1", questions: [q1, q2]),
                .fixture(id: "sub2", questions: [q3])
            ])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat])
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q2")
            store.toggle("q3")
            let result = vm.questions(for: store)
            #expect(result.map(\.id) == ["q1", "q2", "q3"])
        }

        @Test @MainActor func unknownIdDoesNotAppear() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let q1 = CardQuestion.fixture(id: "q1")
            let cat = Talk.Category.fixture(subcategories: [.fixture(questions: [q1])])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat])
            let store = LikesStore()
            store.toggle("unknown_id")
            #expect(vm.questions(for: store).isEmpty)
        }
    }

    @Suite("load(allCategories:)")
    struct Load {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.liked.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test @MainActor func afterLoadReturnsData() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let q1 = CardQuestion.fixture(id: "q1")
            let cat = Talk.Category.fixture(subcategories: [.fixture(questions: [q1])])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat])
            let store = LikesStore()
            store.toggle("q1")
            #expect(vm.questions(for: store).count == 1)
        }

        @Test @MainActor func reloadReplacesCategories() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let q1 = CardQuestion.fixture(id: "q1")
            let q2 = CardQuestion.fixture(id: "q2")
            let cat1 = Talk.Category.fixture(id: "cat1", subcategories: [.fixture(questions: [q1])])
            let cat2 = Talk.Category.fixture(id: "cat2", subcategories: [.fixture(questions: [q2])])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat1])
            vm.load(allCategories: [cat2])
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q2")
            let result = vm.questions(for: store)
            #expect(result.count == 1)
            #expect(result[0].id == "q2")
        }
    }
}
