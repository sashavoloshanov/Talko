import Testing
import Foundation

@Suite("CategoryProvider", .serialized)
@MainActor
struct CategoryProviderTests {

    private func makeDefaults() -> (UserDefaults, String) {
        let suite = "com.talk.widget.catprovider.\(UUID().uuidString)"
        return (UserDefaults(suiteName: suite)!, suite)
    }

    @Suite("loadQuestions(from:)")
    @MainActor
    struct LoadQuestions {
        private func makeDefaults() -> (UserDefaults, String) {
            let suite = "com.talk.widget.catprovider.\(UUID().uuidString)"
            return (UserDefaults(suiteName: suite)!, suite)
        }

        @Test func nilDefaults_returnsEmpty() {
            let provider = CategoryProvider(categoryId: "couple")
            #expect(provider.loadQuestions(from: nil).isEmpty)
        }

        @Test func noQuestionsKey_returnsEmpty() {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let provider = CategoryProvider(categoryId: "couple")
            #expect(provider.loadQuestions(from: defaults).isEmpty)
        }

        @Test func validQuestions_returnsArray() throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let questions = ["Q1", "Q2", "Q3"]
            let data = try JSONEncoder().encode(questions)
            defaults.set(data, forKey: AppGroupKey.widgetQuestions(categoryId: "couple"))
            let provider = CategoryProvider(categoryId: "couple")
            let result = provider.loadQuestions(from: defaults)
            #expect(result == ["Q1", "Q2", "Q3"])
        }

        @Test func invalidData_returnsEmpty() {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set(Data([0xFF, 0xFE]), forKey: AppGroupKey.widgetQuestions(categoryId: "couple"))
            let provider = CategoryProvider(categoryId: "couple")
            #expect(provider.loadQuestions(from: defaults).isEmpty)
        }
    }

    @Suite("makeEntry(defaults:)")
    @MainActor
    struct MakeEntry {
        private func makeDefaults() -> (UserDefaults, String) {
            let suite = "com.talk.widget.catprovider.\(UUID().uuidString)"
            return (UserDefaults(suiteName: suite)!, suite)
        }

        @Test func nilDefaults_returnsReloadEntry() {
            let provider = CategoryProvider(categoryId: "couple")
            let entry = provider.makeEntry(defaults: nil)
            #expect(entry.questionText == "Reload")
            #expect(entry.categoryId == "couple")
            #expect(entry.categoryName == "couple")
            #expect(entry.totalCount == 1)
            #expect(entry.currentIndex == 1)
        }

        @Test func emptyQuestions_returnsReloadEntry() {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let provider = CategoryProvider(categoryId: "couple")
            let entry = provider.makeEntry(defaults: defaults)
            #expect(entry.questionText == "Reload")
            #expect(entry.totalCount == 1)
        }

        @Test func withQuestions_returnsFirstAtIndex0() throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let questions = ["Question A", "Question B", "Question C"]
            let data = try JSONEncoder().encode(questions)
            defaults.set(data, forKey: AppGroupKey.widgetQuestions(categoryId: "couple"))
            defaults.set(0, forKey: AppGroupKey.widgetIndex(categoryId: "couple"))
            let provider = CategoryProvider(categoryId: "couple")
            let entry = provider.makeEntry(defaults: defaults)
            #expect(entry.questionText == "Question A")
            #expect(entry.currentIndex == 1)
            #expect(entry.totalCount == 3)
        }

        @Test func withQuestionsAtIndex1_returnsSecond() throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let questions = ["Q1", "Q2", "Q3"]
            let data = try JSONEncoder().encode(questions)
            defaults.set(data, forKey: AppGroupKey.widgetQuestions(categoryId: "couple"))
            defaults.set(1, forKey: AppGroupKey.widgetIndex(categoryId: "couple"))
            let provider = CategoryProvider(categoryId: "couple")
            let entry = provider.makeEntry(defaults: defaults)
            #expect(entry.questionText == "Q2")
            #expect(entry.currentIndex == 2)
        }

        @Test func outOfBoundsIndex_clampsToZero() throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let questions = ["Q1", "Q2"]
            let data = try JSONEncoder().encode(questions)
            defaults.set(data, forKey: AppGroupKey.widgetQuestions(categoryId: "couple"))
            defaults.set(99, forKey: AppGroupKey.widgetIndex(categoryId: "couple"))
            let provider = CategoryProvider(categoryId: "couple")
            let entry = provider.makeEntry(defaults: defaults)
            // 99 % 2 = 1
            #expect(entry.questionText == "Q2")
        }

        @Test func categoryNameAndEmoji_fromDefaults() throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set("Couple", forKey: AppGroupKey.widgetCategoryName(categoryId: "couple"))
            defaults.set("💑", forKey: AppGroupKey.widgetCategoryEmoji(categoryId: "couple"))
            let provider = CategoryProvider(categoryId: "couple")
            let entry = provider.makeEntry(defaults: defaults)
            #expect(entry.categoryName == "Couple")
            #expect(entry.categoryEmoji == "💑")
        }

        @Test func missingCategoryName_fallsBackToCategoryId() {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let provider = CategoryProvider(categoryId: "family")
            let entry = provider.makeEntry(defaults: defaults)
            #expect(entry.categoryName == "family")
        }
    }
}
