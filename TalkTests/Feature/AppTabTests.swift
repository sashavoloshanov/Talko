import Testing
import Foundation
@testable import Talk

@Suite("AppTab", .serialized)
@MainActor
struct AppTabTests {

    @Test func allCasesHasThreeElements() {
        #expect(AppTab.allCases.count == 3)
    }

    @Suite("rawValue")
    @MainActor
    struct RawValues {
        @Test func homeRawValue() { #expect(AppTab.home.rawValue == 0) }
        @Test func badgesRawValue() { #expect(AppTab.badges.rawValue == 1) }
        @Test func settingsRawValue() { #expect(AppTab.settings.rawValue == 2) }
    }

    @Suite("id")
    @MainActor
    struct Id {
        @Test func idEqualsRawValue() {
            for tab in AppTab.allCases {
                #expect(tab.id == tab.rawValue)
            }
        }
    }

    @Suite("icon")
    @MainActor
    struct Icon {
        @Test func homeIcon() { #expect(AppTab.home.icon == "homeIcon") }
        @Test func badgesIcon() { #expect(AppTab.badges.icon == "badgeIcon") }
        @Test func settingsIcon() { #expect(AppTab.settings.icon == "settingsIcon") }
    }

    @Suite("title(in:)")
    @MainActor
    struct Title {
        @Test func allTabsHaveNonEmptyTitle() {
            for tab in AppTab.allCases {
                #expect(!tab.title(in: .main).isEmpty)
            }
        }

        @Test func allTabsHaveDistinctTitles() {
            let titles = AppTab.allCases.map { $0.title(in: .main) }
            #expect(Set(titles).count == AppTab.allCases.count)
        }
    }
}
