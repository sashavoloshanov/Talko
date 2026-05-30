import Foundation
 
struct DailyQuestion: Codable {
    let text: String
}

struct DailyQuestionsPayload: Decodable {
    let questions: [String]
    let holidays: [String: String]

    func holidayQuestion(for date: Date) -> String? {
        let key = Self.holidayKey(for: date)
        return holidays[key]
    }

    func question(for date: Date) -> String {
        let dayOfYear = Self.dayOfYear(for: date)
        let index = (dayOfYear - 1) % questions.count
        return questions[index]
    }

    private static func holidayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: date)
    }

    private static func dayOfYear(for date: Date) -> Int {
        Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
    }
}
