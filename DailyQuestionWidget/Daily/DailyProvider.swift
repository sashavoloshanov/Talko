import WidgetKit
import Foundation

struct DailyProvider: TimelineProvider {

    func placeholder(in context: Context) -> DailyEntry {
        DailyEntry(date: .now, questionText: WidgetFallback.placeholderDailyQuestion)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyEntry) -> Void) {
        let payload = loadPayload()
        completion(DailyEntry(date: .now, questionText: questionText(for: .now, payload: payload)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyEntry>) -> Void) {
        let payload = loadPayload()
        completion(Timeline(entries: makeEntries(from: .now, payload: payload), policy: .atEnd))
    }

    // The first entry is dated `now` so WidgetKit renders it immediately —
    // past-dated entries are dropped when a new timeline is applied.
    // The remaining entries switch the question at each upcoming midnight.
    func makeEntries(from date: Date, payload: DailyQuestionsPayload?, calendar: Calendar = .current) -> [DailyEntry] {
        let today = DailyEntry(date: date, questionText: questionText(for: date, payload: payload))
        let upcoming: [DailyEntry] = (1..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: date) else { return nil }
            let entryDate = calendar.startOfDay(for: day)
            return DailyEntry(date: entryDate, questionText: questionText(for: entryDate, payload: payload))
        }
        return [today] + upcoming
    }

    func questionText(for date: Date, payload: DailyQuestionsPayload?) -> String {
        guard let payload, !payload.questions.isEmpty else {
            return WidgetFallback.dailyQuestion
        }
        return payload.holidayQuestion(for: date) ?? payload.question(for: date)
    }

    func loadPayload(defaults: UserDefaults? = UserDefaults(suiteName: AppGroupKey.suiteName)) -> DailyQuestionsPayload? {
        let langCode = defaults?.string(forKey: AppGroupKey.appLanguage) ?? "uk"
        let bundle = Bundle(path: Bundle.main.path(forResource: langCode, ofType: "lproj") ?? "") ?? .main
        guard
            let url = bundle.url(forResource: "daily", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(DailyQuestionsPayload.self, from: data)
    }
}
