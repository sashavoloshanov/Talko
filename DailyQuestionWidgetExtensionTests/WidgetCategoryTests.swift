import Testing
import Foundation

@Suite("WidgetCategory", .serialized)
@MainActor
struct WidgetCategoryTests {

    @Suite("rawValues")
    @MainActor
    struct RawValues {
        @Test func coupleRawValue() { #expect(WidgetCategory.couple.rawValue == "couple") }
        @Test func familyRawValue() { #expect(WidgetCategory.family.rawValue == "family") }
        @Test func friendsRawValue() { #expect(WidgetCategory.friends.rawValue == "friends") }
    }

    @Suite("displayName")
    @MainActor
    struct DisplayName {
        @Test func coupleDisplayName() { #expect(WidgetCategory.couple.displayName == "💑 Couple") }
        @Test func familyDisplayName() { #expect(WidgetCategory.family.displayName == "🏠 Family") }
        @Test func friendsDisplayName() { #expect(WidgetCategory.friends.displayName == "🫂 Friends") }
    }

    @Test func allCasesCount() {
        #expect(WidgetCategory.allCases.count == 3)
    }
}
