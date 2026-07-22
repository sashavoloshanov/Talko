import Testing
import Foundation
@testable import Talk

@Suite("QuestionClientHolder")
@MainActor
struct QuestionClientHolderTests {

    @Suite("load() — success")
    @MainActor
    struct LoadSuccess {
        @Test func categoriesSetFromStub() async throws {
            let mock = MockQuestionClient()
            await mock.setCategories([.fixture()])
            let holder = QuestionClientHolder(client: mock)
            try await holder.load(language: .english)
            #expect(holder.categories.count == 1)
        }

        @Test func dailyQuestionSetFromStub() async throws {
            let mock = MockQuestionClient()
            await mock.setDailyQuestion(DailyQuestion(text: "Test question"))
            let holder = QuestionClientHolder(client: mock)
            try await holder.load(language: .english)
            #expect(holder.dailyQuestion?.text == "Test question")
        }

        @Test func isLoadingFalseAfterCompletion() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            try await holder.load(language: .english)
            #expect(holder.isLoading == false)
        }

        @Test func loadedLanguageSetAfterSuccess() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            try await holder.load(language: .english)
            #expect(holder.loadedLanguage == .english)
        }
    }

    @Suite("subcategory(withId:)")
    @MainActor
    struct SubcategoryLookup {
        @Test func returnsSubcategoryAfterLoad() async throws {
            let sub = Subcategory.fixture(id: "sub42", questions: [.fixture(id: "q42")])
            let mock = MockQuestionClient()
            await mock.setCategories([.fixture(subcategories: [sub])])
            let holder = QuestionClientHolder(client: mock)
            try await holder.load(language: .english)
            #expect(holder.subcategory(withId: "sub42")?.questions.first?.id == "q42")
        }

        @Test func unknownIdReturnsNil() async throws {
            let mock = MockQuestionClient()
            await mock.setCategories([.fixture()])
            let holder = QuestionClientHolder(client: mock)
            try await holder.load(language: .english)
            #expect(holder.subcategory(withId: "missing") == nil)
        }

        @Test func beforeLoadReturnsNil() {
            let holder = QuestionClientHolder(client: MockQuestionClient())
            #expect(holder.subcategory(withId: "sub1") == nil)
        }

        @Test func coversAllSubcategoriesAcrossCategories() async throws {
            let cats: [Talk.Category] = [
                .fixture(id: "c1", subcategories: [.fixture(id: "s1"), .fixture(id: "s2")]),
                .fixture(id: "c2", subcategories: [.fixture(id: "s3")])
            ]
            let mock = MockQuestionClient()
            await mock.setCategories(cats)
            let holder = QuestionClientHolder(client: mock)
            try await holder.load(language: .english)
            #expect(holder.subcategoriesById.count == 3)
        }
    }

    @Suite("Deduplication")
    @MainActor
    struct Deduplication {
        @Test func loadSameLanguageTwiceCallsOnce() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            try await holder.load(language: .english)
            try await holder.load(language: .english)
            let count = await mock.loadCategoriesCallCount
            #expect(count == 1)
        }

        @Test func loadDifferentLanguagesCallsTwice() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            try await holder.load(language: .english)
            try await holder.load(language: .ukrainian)
            let count = await mock.loadCategoriesCallCount
            #expect(count == 2)
        }
    }

    @Suite("reload()")
    @MainActor
    struct Reload {
        @Test func afterReloadLoadedLanguageIsNil() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            try await holder.load(language: .english)
            holder.reload()
            #expect(holder.loadedLanguage == nil)
        }

        @Test func afterReloadNextLoadExecutes() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            try await holder.load(language: .english)
            holder.reload()
            try await holder.load(language: .english)
            let count = await mock.loadCategoriesCallCount
            #expect(count == 2)
        }

        @Test func isLoadingFalseAfterReload() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            try await holder.load(language: .english)
            holder.reload()
            #expect(holder.isLoading == false)
        }
    }

    @Suite("load() — error")
    @MainActor
    struct LoadError {
        @Test func throwingClientThrows() async {
            let mock = MockQuestionClient()
            await mock.setThrow(true)
            let holder = QuestionClientHolder(client: mock)
            await #expect(throws: (any Error).self) {
                try await holder.load(language: .english)
            }
        }

        @Test func isLoadingFalseAfterError() async {
            let mock = MockQuestionClient()
            await mock.setThrow(true)
            let holder = QuestionClientHolder(client: mock)
            try? await holder.load(language: .english)
            #expect(holder.isLoading == false)
        }

        @Test func categoriesEmptyAfterError() async {
            let mock = MockQuestionClient()
            await mock.setThrow(true)
            let holder = QuestionClientHolder(client: mock)
            try? await holder.load(language: .english)
            #expect(holder.categories.isEmpty)
        }
    }
}

extension MockQuestionClient {
    func setCategories(_ cats: [Talk.Category]) {
        stubbedCategories = cats
    }

    func setDailyQuestion(_ q: DailyQuestion) {
        stubbedDailyQuestion = q
    }
}
