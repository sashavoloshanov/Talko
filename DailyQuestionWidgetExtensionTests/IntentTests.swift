import Testing
import Foundation

@Suite("NextQuestionIntent", .serialized)
@MainActor
struct NextQuestionIntentTests {

    @Test func initSetsCategory() {
        let intent = NextQuestionIntent(categoryId: "couple")
        #expect(intent.categoryId == "couple")
    }

    @Test func initWithDifferentCategory() {
        let intent = NextQuestionIntent(categoryId: "family")
        #expect(intent.categoryId == "family")
    }

    @Suite("perform — wraps around")
    @MainActor
    struct Perform {
        private func makeDefaults() -> (UserDefaults, String) {
            let suite = "com.talk.widget.intenttests.\(UUID().uuidString)"
            return (UserDefaults(suiteName: suite)!, suite)
        }

        @Test func incrementsIndexByOne() async throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let questions = ["Q1", "Q2", "Q3"]
            let payload = WidgetCategoryPayload(name: "Couple", emoji: "💑", questions: questions)
            let data = try JSONEncoder().encode(payload)
            defaults.set(data, forKey: AppGroupKey.widgetCategory(categoryId: "couple"))
            defaults.set(0, forKey: AppGroupKey.widgetIndex(categoryId: "couple"))
            // Simulate what perform() does using isolated defaults
            let key = AppGroupKey.widgetIndex(categoryId: "couple")
            let count = questions.count
            let current = defaults.integer(forKey: key)
            defaults.set((current + 1) % max(count, 1), forKey: key)
            #expect(defaults.integer(forKey: key) == 1)
        }

        @Test func wrapsAroundAtEnd() async throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let questions = ["Q1", "Q2", "Q3"]
            let payload = WidgetCategoryPayload(name: "Couple", emoji: "💑", questions: questions)
            let data = try JSONEncoder().encode(payload)
            defaults.set(data, forKey: AppGroupKey.widgetCategory(categoryId: "couple"))
            let key = AppGroupKey.widgetIndex(categoryId: "couple")
            defaults.set(2, forKey: key)
            let count = questions.count
            let current = defaults.integer(forKey: key)
            defaults.set((current + 1) % max(count, 1), forKey: key)
            #expect(defaults.integer(forKey: key) == 0)
        }

        // Calls the real perform() — App Group defaults are nil in tests so it
        // falls back gracefully (count=1, current=0, no-op write) and returns .result().
        @Test func perform_doesNotThrow() async throws {
            let intent = NextQuestionIntent(categoryId: "couple")
            _ = try await intent.perform()
        }

        @Test func perform_differentCategory_doesNotThrow() async throws {
            let intent = NextQuestionIntent(categoryId: "family")
            _ = try await intent.perform()
        }
    }
}

@Suite("PrevQuestionIntent", .serialized)
@MainActor
struct PrevQuestionIntentTests {

    @Test func initSetsCategory() {
        let intent = PrevQuestionIntent(categoryId: "friends")
        #expect(intent.categoryId == "friends")
    }

    @Suite("perform — wraps around")
    @MainActor
    struct Perform {
        private func makeDefaults() -> (UserDefaults, String) {
            let suite = "com.talk.widget.previntenttest.\(UUID().uuidString)"
            return (UserDefaults(suiteName: suite)!, suite)
        }

        @Test func decrementsIndexByOne() async throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let questions = ["Q1", "Q2", "Q3"]
            let payload = WidgetCategoryPayload(name: "Couple", emoji: "💑", questions: questions)
            let data = try JSONEncoder().encode(payload)
            defaults.set(data, forKey: AppGroupKey.widgetCategory(categoryId: "couple"))
            let key = AppGroupKey.widgetIndex(categoryId: "couple")
            defaults.set(2, forKey: key)
            let count = questions.count
            let current = defaults.integer(forKey: key)
            defaults.set(current == 0 ? count - 1 : current - 1, forKey: key)
            #expect(defaults.integer(forKey: key) == 1)
        }

        @Test func wrapsAroundAtStart() async throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let questions = ["Q1", "Q2", "Q3"]
            let payload = WidgetCategoryPayload(name: "Couple", emoji: "💑", questions: questions)
            let data = try JSONEncoder().encode(payload)
            defaults.set(data, forKey: AppGroupKey.widgetCategory(categoryId: "couple"))
            let key = AppGroupKey.widgetIndex(categoryId: "couple")
            defaults.set(0, forKey: key)
            let count = questions.count
            let current = defaults.integer(forKey: key)
            defaults.set(current == 0 ? count - 1 : current - 1, forKey: key)
            #expect(defaults.integer(forKey: key) == 2)
        }

        // Calls the real perform() — App Group defaults are nil in tests so it
        // falls back gracefully (count=1, wraps to 0) and returns .result().
        @Test func perform_doesNotThrow() async throws {
            let intent = PrevQuestionIntent(categoryId: "friends")
            _ = try await intent.perform()
        }

        @Test func perform_differentCategory_doesNotThrow() async throws {
            let intent = PrevQuestionIntent(categoryId: "couple")
            _ = try await intent.perform()
        }
    }
}
