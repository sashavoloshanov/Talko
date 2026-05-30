import WidgetKit
import SwiftUI

private func makeCategoryWidget(kind: String, categoryId: String) -> some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: CategoryProvider(categoryId: categoryId)) { entry in
        LargeWidgetView(entry: entry)
            .containerBackground(.fill.tertiary, for: .widget)
    }
    .supportedFamilies([.systemLarge])
}

struct CoupleQuestionWidget: Widget {
    let kind = "CategoryWidget_couple"

    var body: some WidgetConfiguration {
        makeCategoryWidget(kind: kind, categoryId: "couple")
            .configurationDisplayName("💑 Couple")
            .description("Questions for couple.")
    }
}

struct FamilyQuestionWidget: Widget {
    let kind = "CategoryWidget_family"

    var body: some WidgetConfiguration {
        makeCategoryWidget(kind: kind, categoryId: "family")
            .configurationDisplayName("🏠 Family")
            .description("Questions for family.")
    }
}

struct FriendsQuestionWidget: Widget {
    let kind = "CategoryWidget_friends"

    var body: some WidgetConfiguration {
        makeCategoryWidget(kind: kind, categoryId: "friends")
            .configurationDisplayName("🫂 Friends")
            .description("Questions for friends.")
    }
}
