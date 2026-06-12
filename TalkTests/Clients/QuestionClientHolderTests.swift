import Testing
@testable import Talk

@Suite("QuestionClientHolder")
@MainActor
struct QuestionClientHolderTests {

    @Suite("load() — успіх")
    struct LoadSuccess {
        @Test func categoriesSetFromStub() async throws {
            let mock = MockQuestionClient()
            await mock.setCategories([.fixture()])
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            try await holder.load(language: .english, premiumClient: premium)
            #expect(holder.categories.count == 1)
        }

        @Test func dailyQuestionSetFromStub() async throws {
            let mock = MockQuestionClient()
            await mock.setDailyQuestion(DailyQuestion(text: "Test question"))
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            try await holder.load(language: .english, premiumClient: premium)
            #expect(holder.dailyQuestion?.text == "Test question")
        }

        @Test func isLoadingFalseAfterCompletion() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            try await holder.load(language: .english, premiumClient: premium)
            #expect(holder.isLoading == false)
        }

        @Test func loadedLanguageSetAfterSuccess() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            try await holder.load(language: .english, premiumClient: premium)
            #expect(holder.loadedLanguage == .english)
        }
    }

    @Suite("Дедуплікація")
    struct Deduplication {
        @Test func loadSameLanguageTwiceCallsOnce() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            try await holder.load(language: .english, premiumClient: premium)
            try await holder.load(language: .english, premiumClient: premium)
            let count = await mock.loadCategoriesCallCount
            #expect(count == 1)
        }

        @Test func loadDifferentLanguagesCallsTwice() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            try await holder.load(language: .english, premiumClient: premium)
            try await holder.load(language: .ukrainian, premiumClient: premium)
            let count = await mock.loadCategoriesCallCount
            #expect(count == 2)
        }
    }

    @Suite("reload()")
    struct Reload {
        @Test func afterReloadLoadedLanguageIsNil() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            try await holder.load(language: .english, premiumClient: premium)
            holder.reload()
            #expect(holder.loadedLanguage == nil)
        }

        @Test func afterReloadNextLoadExecutes() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            try await holder.load(language: .english, premiumClient: premium)
            holder.reload()
            try await holder.load(language: .english, premiumClient: premium)
            let count = await mock.loadCategoriesCallCount
            #expect(count == 2)
        }

        @Test func isLoadingFalseAfterReload() async throws {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            try await holder.load(language: .english, premiumClient: premium)
            holder.reload()
            #expect(holder.isLoading == false)
        }
    }

    @Suite("load() — помилка")
    struct LoadError {
        @Test func throwingClientThrows() async {
            let mock = MockQuestionClient()
            await mock.setThrow(true)
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            await #expect(throws: (any Error).self) {
                try await holder.load(language: .english, premiumClient: premium)
            }
        }

        @Test func isLoadingFalseAfterError() async {
            let mock = MockQuestionClient()
            await mock.setThrow(true)
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            try? await holder.load(language: .english, premiumClient: premium)
            #expect(holder.isLoading == false)
        }

        @Test func categoriesEmptyAfterError() async {
            let mock = MockQuestionClient()
            await mock.setThrow(true)
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            try? await holder.load(language: .english, premiumClient: premium)
            #expect(holder.categories.isEmpty)
        }
    }
}

extension MockQuestionClient {
    func setCategories(_ cats: [Category]) {
        stubbedCategories = cats
    }

    func setDailyQuestion(_ q: DailyQuestion) {
        stubbedDailyQuestion = q
    }
}
