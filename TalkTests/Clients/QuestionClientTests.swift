import Testing
@testable import Talk
import Foundation

private func makeBundle(dailyJSON: String) throws -> Bundle {
    let tmp = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    let lproj = tmp.appendingPathComponent("en.lproj")
    try FileManager.default.createDirectory(at: lproj, withIntermediateDirectories: true)
    try dailyJSON.write(to: lproj.appendingPathComponent("daily.json"), atomically: true, encoding: .utf8)
    return Bundle(path: tmp.path)!
}

private func makeCategoryBundle(categories: [String: String]) throws -> Bundle {
    let tmp = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    let lproj = tmp.appendingPathComponent("en.lproj")
    try FileManager.default.createDirectory(at: lproj, withIntermediateDirectories: true)
    for (name, json) in categories {
        try json.write(to: lproj.appendingPathComponent("\(name).json"), atomically: true, encoding: .utf8)
    }
    return Bundle(path: tmp.path)!
}

private func makeWidgetDefaults() -> (UserDefaults, String) {
    let suite = "com.talk.widget.tests.\(UUID().uuidString)"
    return (UserDefaults(suiteName: suite)!, suite)
}

private let coupleJSON = """
{
  "id": "couple",
  "name": "Couple",
  "emoji": "💑",
  "subcategories": [
    {
      "id": "sub_free",
      "emoji": "💬",
      "name": "Free Sub",
      "description": "Free",
      "isPremium": false,
      "questions": [{"id": "qf1", "text": "Free Q"}]
    },
    {
      "id": "sub_premium",
      "emoji": "⭐",
      "name": "Premium Sub",
      "description": "Premium",
      "isPremium": true,
      "questions": [{"id": "qp1", "text": "Premium Q"}]
    }
  ]
}
"""

private let minimalCategoryJSON = """
{
  "id": "%@",
  "name": "%@",
  "emoji": "📦",
  "subcategories": []
}
"""

@Suite("QuestionClient")
struct QuestionClientTests {

    @Suite("loadDailyQuestion")
    struct LoadDailyQuestion {

        @Test func emptyQuestionsThrows() async throws {
            let bundle = try makeBundle(dailyJSON: #"{"questions":[],"holidays":{}}"#)
            let (widgetDefaults, suite) = makeWidgetDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let widgetCenter = MockWidgetCenter()
            let client = QuestionClient(contentBundle: bundle, widgetDefaults: widgetDefaults, widgetCenter: widgetCenter)
            await #expect(throws: (any Error).self) {
                try await client.loadDailyQuestion(language: .english)
            }
        }

        @Test func normalJSONReturnsQuestion() async throws {
            let bundle = try makeBundle(dailyJSON: #"{"questions":["Q1","Q2","Q3"],"holidays":{}}"#)
            let (widgetDefaults, suite) = makeWidgetDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let widgetCenter = MockWidgetCenter()
            let client = QuestionClient(contentBundle: bundle, widgetDefaults: widgetDefaults, widgetCenter: widgetCenter)
            let result = try await client.loadDailyQuestion(language: .english)
            #expect(!result.text.isEmpty)
        }

        @Test func holidayJSONReturnsHolidayQuestion() async throws {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd"
            let todayKey = formatter.string(from: Date())
            let json = #"{"questions":["Regular Q"],"holidays":{"\#(todayKey)":"Holiday Q"}}"#
            let bundle = try makeBundle(dailyJSON: json)
            let (widgetDefaults, suite) = makeWidgetDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let widgetCenter = MockWidgetCenter()
            let client = QuestionClient(contentBundle: bundle, widgetDefaults: widgetDefaults, widgetCenter: widgetCenter)
            let result = try await client.loadDailyQuestion(language: .english)
            #expect(result.text == "Holiday Q")
        }

        @Test func doesNotTouchWidgetDefaults() async throws {
            let bundle = try makeBundle(dailyJSON: #"{"questions":["Widget Q"],"holidays":{}}"#)
            let (widgetDefaults, suite) = makeWidgetDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let widgetCenter = MockWidgetCenter()
            let client = QuestionClient(contentBundle: bundle, widgetDefaults: widgetDefaults, widgetCenter: widgetCenter)
            let result = try await client.loadDailyQuestion(language: .english)
            #expect(result.text == "Widget Q")
            #expect(widgetCenter.reloadedKinds.isEmpty)
        }
    }

    @Suite("fileURL")
    struct FileURL {
        @Test func missingFileThrowsFileNotFound() async throws {
            let bundle = try makeBundle(dailyJSON: #"{"questions":["Q1"],"holidays":{}}"#)
            let client = QuestionClient(contentBundle: bundle, widgetDefaults: nil, widgetCenter: MockWidgetCenter())
            await #expect(throws: (any Error).self) {
                try await client.loadCategories(language: .english)
            }
        }
    }

    @Suite("saveQuestionsForWidget (via loadCategories)")
    struct SaveQuestionsForWidget {

        private func makeAllCategoryBundle(coupleOverride: String? = nil) throws -> Bundle {
            let couple = coupleOverride ?? coupleJSON
            let family = String(format: minimalCategoryJSON, "family", "Family")
            let friends = String(format: minimalCategoryJSON, "friends", "Friends")
            return try makeCategoryBundle(categories: ["couple": couple, "family": family, "friends": friends])
        }

        @Test func notPremiumSavesOnlyFreeQuestions() async throws {
            let bundle = try makeAllCategoryBundle()
            let (widgetDefaults, suite) = makeWidgetDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            widgetDefaults.set(false, forKey: AppGroupKey.isPremium)
            let widgetCenter = MockWidgetCenter()
            let client = QuestionClient(contentBundle: bundle, widgetDefaults: widgetDefaults, widgetCenter: widgetCenter)
            _ = try await client.loadCategories(language: .english)
            let data = widgetDefaults.data(forKey: AppGroupKey.widgetQuestions(categoryId: "couple"))
            let questions = try JSONDecoder().decode([String].self, from: data!)
            #expect(questions.contains("Free Q"))
            #expect(!questions.contains("Premium Q"))
        }

        @Test func premiumSavesAllQuestions() async throws {
            let bundle = try makeAllCategoryBundle()
            let (widgetDefaults, suite) = makeWidgetDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            widgetDefaults.set(true, forKey: AppGroupKey.isPremium)
            let widgetCenter = MockWidgetCenter()
            let client = QuestionClient(contentBundle: bundle, widgetDefaults: widgetDefaults, widgetCenter: widgetCenter)
            _ = try await client.loadCategories(language: .english)
            let data = widgetDefaults.data(forKey: AppGroupKey.widgetQuestions(categoryId: "couple"))
            let questions = try JSONDecoder().decode([String].self, from: data!)
            #expect(questions.contains("Free Q"))
            #expect(questions.contains("Premium Q"))
        }

        @Test func widgetDefaultsContainsCategoryNameAndEmoji() async throws {
            let bundle = try makeAllCategoryBundle()
            let (widgetDefaults, suite) = makeWidgetDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let client = QuestionClient(contentBundle: bundle, widgetDefaults: widgetDefaults, widgetCenter: MockWidgetCenter())
            _ = try await client.loadCategories(language: .english)
            #expect(widgetDefaults.string(forKey: AppGroupKey.widgetCategoryName(categoryId: "couple")) == "Couple")
            #expect(widgetDefaults.string(forKey: AppGroupKey.widgetCategoryEmoji(categoryId: "couple")) == "💑")
        }

        @Test func reloadedAllTrueAfterLoadCategories() async throws {
            let bundle = try makeAllCategoryBundle()
            let (widgetDefaults, suite) = makeWidgetDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let widgetCenter = MockWidgetCenter()
            let client = QuestionClient(contentBundle: bundle, widgetDefaults: widgetDefaults, widgetCenter: widgetCenter)
            _ = try await client.loadCategories(language: .english)
            #expect(widgetCenter.reloadedAll == true)
        }
    }
}
