import Testing
import Foundation
@testable import Talk

@Suite("AppSheet + AppFullScreenCover")
@MainActor
struct AppSheetTests {

    private func sampleBadge(id: String = "b1") -> Badge {
        Badge.fixture(id: id)
    }

    @Suite("AppSheet.id")
    @MainActor
    struct AppSheetID {
        @Test func subscription_idIsSelf() {
            let sheet = AppSheet.subscription
            #expect(sheet.id == sheet)
        }

        @Test func document_idIsSelf() {
            let sheet = AppSheet.document(.privacyPolicy)
            #expect(sheet.id == sheet)
        }

        @Test func document_support_idIsSelf() {
            let sheet = AppSheet.document(.support)
            #expect(sheet.id == sheet)
        }

        @Test func differentCases_idsAreNotEqual() {
            #expect(AppSheet.subscription.id != AppSheet.document(.privacyPolicy).id)
        }

        @Test func sameCase_idsAreEqual() {
            #expect(AppSheet.subscription.id == AppSheet.subscription.id)
        }
    }

    @Suite("AppFullScreenCover.id")
    @MainActor
    struct AppFullScreenCoverID {
        @Test func badge_idIsSelf() {
            let badge = Badge.fixture(id: "x")
            let cover = AppFullScreenCover.badge(badge)
            #expect(cover.id == cover)
        }

        @Test func sameBadge_idsAreEqual() {
            let badge = Badge.fixture(id: "x")
            let cover1 = AppFullScreenCover.badge(badge)
            let cover2 = AppFullScreenCover.badge(badge)
            #expect(cover1.id == cover2.id)
        }

        @Test func differentBadge_idsAreNotEqual() {
            let b1 = Badge.fixture(id: "a")
            let b2 = Badge.fixture(id: "b")
            #expect(AppFullScreenCover.badge(b1).id != AppFullScreenCover.badge(b2).id)
        }
    }
}
