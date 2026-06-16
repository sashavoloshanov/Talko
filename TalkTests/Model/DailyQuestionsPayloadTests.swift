import Testing
import Foundation
@testable import Talk

private func date(month: Int, day: Int) -> Date {
    var c = DateComponents()
    c.year = 2024
    c.month = month
    c.day = day
    return Calendar.current.date(from: c)!
}

@Suite("DailyQuestionsPayload")
struct DailyQuestionsPayloadTests {

    @Suite("holidayQuestion(for:)")
    struct HolidayQuestion {
        @Test func returnsQuestionWhenKeyMatches() {
            let payload = DailyQuestionsPayload(questions: ["Q1"], holidays: ["12-25": "Merry Christmas!"])
            #expect(payload.holidayQuestion(for: date(month: 12, day: 25)) == "Merry Christmas!")
        }

        @Test func returnsNilForDayWithoutHoliday() {
            let payload = DailyQuestionsPayload(questions: ["Q1"], holidays: ["12-25": "Merry Christmas!"])
            #expect(payload.holidayQuestion(for: date(month: 12, day: 24)) == nil)
        }

        @Test func returnsNilWhenHolidaysEmpty() {
            let payload = DailyQuestionsPayload(questions: ["Q1"], holidays: [:])
            #expect(payload.holidayQuestion(for: date(month: 12, day: 25)) == nil)
        }
    }

    @Suite("holidayKey formatting")
    struct HolidayKeyFormatting {
        @Test func december25FormatIsCorrect() {
            let payload = DailyQuestionsPayload(questions: ["Q1"], holidays: ["12-25": "X"])
            #expect(payload.holidayQuestion(for: date(month: 12, day: 25)) == "X")
        }

        @Test func january5HasZeroPadding() {
            let payload = DailyQuestionsPayload(questions: ["Q1"], holidays: ["01-05": "Y"])
            #expect(payload.holidayQuestion(for: date(month: 1, day: 5)) == "Y")
        }
    }

    @Suite("question(for:)")
    struct QuestionFor {
        let payload = DailyQuestionsPayload(questions: ["A", "B", "C"], holidays: [:])

        @Test func dayOfYear1ReturnsIndex0() {
            let jan1 = date(month: 1, day: 1)
            #expect(payload.question(for: jan1) == "A")
        }

        @Test func dayOfYear2ReturnsIndex1() {
            let jan2 = date(month: 1, day: 2)
            #expect(payload.question(for: jan2) == "B")
        }

        @Test func wrapAroundWhenDayExceedsCount() {
            let jan4 = date(month: 1, day: 4)
            #expect(payload.question(for: jan4) == "A")
        }

        @Test func sameDateAlwaysReturnsSameResult() {
            let d = date(month: 6, day: 15)
            #expect(payload.question(for: d) == payload.question(for: d))
        }
    }

    @Suite("Priority")
    struct Priority {
        @Test func holidayOverridesRegularQuestion() {
            let payload = DailyQuestionsPayload(questions: ["Regular"], holidays: ["01-01": "New Year!"])
            let jan1 = date(month: 1, day: 1)
            #expect(payload.holidayQuestion(for: jan1) == "New Year!")
            #expect(payload.holidayQuestion(for: jan1) != payload.question(for: jan1))
        }
    }
}
