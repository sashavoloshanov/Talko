import WidgetKit
import SwiftUI

struct DailyQuestionWidget: Widget {
    let kind = "DailyQuestionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyProvider()) { entry in
            DailyWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Питання дня")
        .description("Щоденне питання оновлюється о півночі.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}


#Preview("Medium", as: .systemMedium) {
    DailyQuestionWidget()
} timeline: {
    DailyEntry(date: .now, questionText: "What made you happy today?")
}

#Preview("Small", as: .systemSmall) {
    DailyQuestionWidget()
} timeline: {
    DailyEntry(date: .now, questionText: "What made you happy today?")
}
