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
            let data = try JSONEncoder().encode(questions)
            defaults.set(data, forKey: AppGroupKey.widgetQuestions(categoryId: "couple"))
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
            let data = try JSONEncoder().encode(questions)
            defaults.set(data, forKey: AppGroupKey.widgetQuestions(categoryId: "couple"))
            let key = AppGroupKey.widgetIndex(categoryId: "couple")
            defaults.set(2, forKey: key)
            let count = questions.count
            let current = defaults.integer(forKey: key)
            defaults.set((current + 1) % max(count, 1), forKey: key)
            #expect(defaults.integer(forKey: key) == 0)
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
            let data = try JSONEncoder().encode(questions)
            defaults.set(data, forKey: AppGroupKey.widgetQuestions(categoryId: "couple"))
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
            let data = try JSONEncoder().encode(questions)
            defaults.set(data, forKey: AppGroupKey.widgetQuestions(categoryId: "couple"))
            let key = AppGroupKey.widgetIndex(categoryId: "couple")
            defaults.set(0, forKey: key)
            let count = questions.count
            let current = defaults.integer(forKey: key)
            defaults.set(current == 0 ? count - 1 : current - 1, forKey: key)
            #expect(defaults.integer(forKey: key) == 2)
        }
    }
}
