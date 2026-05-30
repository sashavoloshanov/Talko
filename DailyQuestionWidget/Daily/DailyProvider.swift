import WidgetKit
import Foundation

struct DailyProvider: TimelineProvider {

    func placeholder(in context: Context) -> DailyEntry {
        DailyEntry(date: .now, questionText: "What made you happy today?")
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyEntry) -> Void) {
        completion(DailyEntry(date: .now, questionText: loadQuestion()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyEntry>) -> Void) {
        let entry = DailyEntry(date: .now, questionText: loadQuestion())
        let midnight = Calendar.current.nextDate(
            after: .now,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) ?? .now.addingTimeInterval(86400)
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func loadQuestion() -> String {
        if let defaults = UserDefaults(suiteName: "group.com.talk.shared"),
           let cached = defaults.string(forKey: "dailyQuestion") {
            return cached
        }
        return loadFromBundle() ?? "What made you happy today?"
    }

    private func loadFromBundle() -> String? {
        guard
            let url = Bundle.main.url(forResource: "daily", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let payload = try? JSONDecoder().decode(DailyQuestionsPayload.self, from: data)
        else { return nil }
        return payload.holidayQuestion(for: .now) ?? payload.question(for: .now)
    }
}
