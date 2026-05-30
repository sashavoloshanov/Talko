import SwiftUI
import WidgetKit

struct DailyWidgetEntryView: View {
    let entry: DailyEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(text: entry.questionText)
        case .systemMedium:
            MediumWidgetView(text: entry.questionText)
        default:
            SmallWidgetView(text: entry.questionText)
        }
    }
}
