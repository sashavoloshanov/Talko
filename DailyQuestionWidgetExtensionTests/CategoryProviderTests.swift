import Testing
import Foundation

private func makeDefaults() -> (UserDefaults, String) {
    let suite = "com.talk.widget.catprovider.\(UUID().uuidString)"
    return (UserDefaults(suiteName: suite)!, suite)
}

private func savePayload(
    _ payload: WidgetCategoryPayload,
    categoryId: String,
    to defaults: UserDefaults
) throws {
    let data = try JSONEncoder().encode(payload)
    defaults.set(data, forKey: AppGroupKey.widgetCategory(categoryId: categoryId))
}

@Suite("CategoryProvider", .serialized)
@MainActor
struct CategoryProviderTests {

    @Suite("loadPayload(from:)")
    @MainActor
    struct LoadPayload {

        @Test func nilDefaults_returnsNil() {
            let provider = CategoryProvider(categoryId: "couple")
            #expect(provider.loadPayload(from: nil) == nil)
        }

        @Test func noPayloadKey_returnsNil() {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let provider = CategoryProvider(categoryId: "couple")
            #expect(provider.loadPayload(from: defaults) == nil)
        }

        @Test func validPayload_returnsDecodedValues() throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let payload = WidgetCategoryPayload(name: "Couple", emoji: "💑", questions: ["Q1", "Q2", "Q3"])
            try savePayload(payload, categoryId: "couple", to: defaults)
            let provider = CategoryProvider(categoryId: "couple")
            let loaded = provider.loadPayload(from: defaults)
            #expect(loaded?.name == "Couple")
            #expect(loaded?.emoji == "💑")
            #expect(loaded?.questions == ["Q1", "Q2", "Q3"])
        }

        @Test func invalidData_returnsNil() {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set(Data([0xFF, 0xFE]), forKey: AppGroupKey.widgetCategory(categoryId: "couple"))
            let provider = CategoryProvider(categoryId: "couple")
            #expect(provider.loadPayload(from: defaults) == nil)
        }
    }

    @Suite("makeEntry(defaults:)")
    @MainActor
    struct MakeEntry {

        @Test func nilDefaults_returnsReloadEntry() {
            let provider = CategoryProvider(categoryId: "couple")
            let entry = provider.makeEntry(defaults: nil)
            #expect(entry.questionText == WidgetFallback.reload)
            #expect(entry.categoryId == "couple")
            #expect(entry.categoryName == "couple")
            #expect(entry.totalCount == 1)
            #expect(entry.currentIndex == 1)
        }

        @Test func missingPayload_returnsReloadEntry() {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let provider = CategoryProvider(categoryId: "couple")
            let entry = provider.makeEntry(defaults: defaults)
            #expect(entry.questionText == WidgetFallback.reload)
            #expect(entry.totalCount == 1)
        }

        @Test func withQuestions_returnsFirstAtIndex0() throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let payload = WidgetCategoryPayload(name: "Couple", emoji: "💑", questions: ["Question A", "Question B", "Question C"])
            try savePayload(payload, categoryId: "couple", to: defaults)
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
            let payload = WidgetCategoryPayload(name: "Couple", emoji: "💑", questions: ["Q1", "Q2", "Q3"])
            try savePayload(payload, categoryId: "couple", to: defaults)
            defaults.set(1, forKey: AppGroupKey.widgetIndex(categoryId: "couple"))
            let provider = CategoryProvider(categoryId: "couple")
            let entry = provider.makeEntry(defaults: defaults)
            #expect(entry.questionText == "Q2")
            #expect(entry.currentIndex == 2)
        }

        @Test func outOfBoundsIndex_wrapsAround() throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let payload = WidgetCategoryPayload(name: "Couple", emoji: "💑", questions: ["Q1", "Q2"])
            try savePayload(payload, categoryId: "couple", to: defaults)
            defaults.set(99, forKey: AppGroupKey.widgetIndex(categoryId: "couple"))
            let provider = CategoryProvider(categoryId: "couple")
            let entry = provider.makeEntry(defaults: defaults)
            // 99 % 2 = 1
            #expect(entry.questionText == "Q2")
        }

        @Test func categoryNameAndEmoji_fromPayload() throws {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let payload = WidgetCategoryPayload(name: "Couple", emoji: "💑", questions: [])
            try savePayload(payload, categoryId: "couple", to: defaults)
            let provider = CategoryProvider(categoryId: "couple")
            let entry = provider.makeEntry(defaults: defaults)
            #expect(entry.categoryName == "Couple")
            #expect(entry.categoryEmoji == "💑")
        }

        @Test func missingPayload_fallsBackToCategoryId() {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let provider = CategoryProvider(categoryId: "family")
            let entry = provider.makeEntry(defaults: defaults)
            #expect(entry.categoryName == "family")
        }
    }
}
