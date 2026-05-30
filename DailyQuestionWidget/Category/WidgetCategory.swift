import AppIntents
import WidgetKit

enum WidgetCategory: String, AppEnum {
    case couple  = "couple"
    case family  = "family"
    case friends = "friends"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Category")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .couple:  "💑 Couple",
        .family:  "🏠 Family",
        .friends: "🫂 Friends"
    ]

    var displayName: String {
        switch self {
        case .couple:  return "💑 Couple"
        case .family:  return "🏠 Family"
        case .friends: return "🫂 Friends"
        }
    }
}

struct CategoryConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Category"
    static var description = IntentDescription("Choose your category for the widget")

    @Parameter(title: "Category", default: .couple)
    var category: WidgetCategory
}
