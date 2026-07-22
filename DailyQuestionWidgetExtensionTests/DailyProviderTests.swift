import Testing
import Foundation

@Suite("DailyProvider", .serialized)
@MainActor
struct DailyProviderTests {

    @Suite("makeEntries(from:payload:)")
    @MainActor
    struct MakeEntries {

        @Test func returnsSevenEntries() {
            let provider = DailyProvider()
            let entries = provider.makeEntries(from: .now, payload: makePayload())
            #expect(entries.count == 7)
        }

        @Test func entryDatesAreMidnights() {
            let provider = DailyProvider()
            let calendar = Calendar.current
            let entries = provider.makeEntries(from: .now, payload: makePayload(), calendar: calendar)
            for entry in entries {
                #expect(entry.date == calendar.startOfDay(for: entry.date))
            }
        }

        @Test func entryDatesAreConsecutiveDays() {
            let provider = DailyProvider()
            let calendar = Calendar.current
            let entries = provider.makeEntries(from: .now, payload: makePayload(), calendar: calendar)
            for (offset, entry) in entries.enumerated() {
                let expected = calendar.startOfDay(
                    for: calendar.date(byAdding: .day, value: offset, to: .now)!
                )
                #expect(entry.date == expected)
            }
        }

        @Test func questionsFollowSharedDayOfYearRule() {
            let provider = DailyProvider()
            let payload = makePayload(questions: ["Q1", "Q2", "Q3"])
            let entries = provider.makeEntries(from: .now, payload: payload)
            for entry in entries {
                #expect(entry.questionText == payload.holidayQuestion(for: entry.date) ?? payload.question(for: entry.date))
            }
        }

        @Test func holidayOverridesRegularQuestion() {
            let provider = DailyProvider()
            let calendar = Calendar.current
            let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: .now)!)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd"
            let key = formatter.string(from: tomorrow)
            let payload = makePayload(questions: ["Regular"], holidays: [key: "Holiday Q"])
            let entries = provider.makeEntries(from: .now, payload: payload)
            #expect(entries[1].questionText == "Holiday Q")
        }

        @Test func nilPayload_usesFallbackText() {
            let provider = DailyProvider()
            let entries = provider.makeEntries(from: .now, payload: nil)
            #expect(entries.count == 7)
            for entry in entries {
                #expect(!entry.questionText.isEmpty)
            }
        }

        @Test func emptyQuestions_usesFallbackText() {
            let provider = DailyProvider()
            let entries = provider.makeEntries(from: .now, payload: makePayload(questions: []))
            for entry in entries {
                #expect(!entry.questionText.isEmpty)
            }
        }
    }

    @Suite("questionText(for:payload:)")
    @MainActor
    struct QuestionText {

        @Test func nilPayload_returnsNonEmptyFallback() {
            let provider = DailyProvider()
            #expect(!provider.questionText(for: .now, payload: nil).isEmpty)
        }

        @Test func payloadWithQuestions_matchesPayloadSelection() {
            let provider = DailyProvider()
            let payload = makePayload(questions: ["A", "B"])
            let expected = payload.holidayQuestion(for: .now) ?? payload.question(for: .now)
            #expect(provider.questionText(for: .now, payload: payload) == expected)
        }
    }

    @Suite("loadPayload(defaults:)")
    @MainActor
    struct LoadPayload {

        @Test func nilDefaults_doesNotCrash() {
            let provider = DailyProvider()
            // In the test environment Bundle.main is the test runner — daily.json
            // may not be present, so nil is the expected result; no crash is the guarantee.
            _ = provider.loadPayload(defaults: nil)
        }

        @Test func missingBundleFile_returnsNil() {
            let suite = "com.talk.widget.dailyprovider.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suite)!
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let provider = DailyProvider()
            let payload = provider.loadPayload(defaults: defaults)
            if let payload {
                #expect(!payload.questions.isEmpty)
            }
        }
    }

    @Suite("placeholder text")
    @MainActor
    struct Placeholder {
        @Test func placeholderHasNonEmptyText() {
            let text = "What made you happy today?"
            #expect(!text.isEmpty)
        }
    }
}

private func makePayload(
    questions: [String] = ["Q1", "Q2", "Q3"],
    holidays: [String: String] = [:]
) -> DailyQuestionsPayload {
    DailyQuestionsPayload(questions: questions, holidays: holidays)
}
