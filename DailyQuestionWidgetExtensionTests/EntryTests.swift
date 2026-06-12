import Testing
import Foundation
import WidgetKit

@Suite("CategoryEntry", .serialized)
@MainActor
struct CategoryEntryTests {

    @Test func propertiesAreStoredCorrectly() {
        let date = Date(timeIntervalSince1970: 0)
        let entry = CategoryEntry(
            date: date,
            questionText: "Test question?",
            categoryId: "couple",
            categoryName: "Couple",
            categoryEmoji: "💑",
            currentIndex: 3,
            totalCount: 10
        )
        #expect(entry.date == date)
        #expect(entry.questionText == "Test question?")
        #expect(entry.categoryId == "couple")
        #expect(entry.categoryName == "Couple")
        #expect(entry.categoryEmoji == "💑")
        #expect(entry.currentIndex == 3)
        #expect(entry.totalCount == 10)
    }
}

@Suite("DailyEntry", .serialized)
@MainActor
struct DailyEntryTests {

    @Test func propertiesAreStoredCorrectly() {
        let date = Date(timeIntervalSince1970: 1000)
        let entry = DailyEntry(date: date, questionText: "What made you happy today?")
        #expect(entry.date == date)
        #expect(entry.questionText == "What made you happy today?")
    }
}
