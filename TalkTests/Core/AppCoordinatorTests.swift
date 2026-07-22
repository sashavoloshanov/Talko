import Testing
import Foundation
@testable import Talk
internal import SwiftUI

private func sampleBadge() -> Badge {
    Badge.fixture(id: "b1")
}

@Suite("AppCoordinator")
@MainActor
struct AppCoordinatorTests {

    @Suite("push / pop")
    @MainActor
    struct PushPop {
        @Test func pushAddsRouteToPath() {
            let coordinator = AppCoordinator()
            coordinator.push(.question(subcategoryId: "s1", title: "T1"))
            #expect(coordinator.path.count == 1)
        }

        @Test func twoPushesResultInCount2() {
            let coordinator = AppCoordinator()
            coordinator.push(.question(subcategoryId: "s1", title: "T1"))
            coordinator.push(.question(subcategoryId: "s2", title: "T2"))
            #expect(coordinator.path.count == 2)
        }

        @Test func popRemovesLastRoute() {
            let coordinator = AppCoordinator()
            coordinator.push(.question(subcategoryId: "s1", title: "T1"))
            coordinator.pop()
            #expect(coordinator.path.count == 0)
        }

        @Test func popOnEmptyPathDoesNotCrash() {
            let coordinator = AppCoordinator()
            coordinator.pop()
            #expect(coordinator.path.count == 0)
        }

        @Test func popToRootClearsAllRoutes() {
            let coordinator = AppCoordinator()
            coordinator.push(.question(subcategoryId: "s1", title: "T1"))
            coordinator.push(.question(subcategoryId: "s2", title: "T2"))
            coordinator.push(.likedQuestions)
            coordinator.popToRoot()
            #expect(coordinator.path.count == 0)
        }
    }

    @Suite("sheet")
    @MainActor
    struct Sheet {
        @Test func presentSheetSetsSheet() {
            let coordinator = AppCoordinator()
            coordinator.present(AppSheet.subscription)
            #expect(coordinator.sheet == .subscription)
        }

        @Test func dismissSheetSetsNil() {
            let coordinator = AppCoordinator()
            coordinator.present(AppSheet.subscription)
            coordinator.dismissSheet()
            #expect(coordinator.sheet == nil)
        }

        @Test func dismissSheetWhenNilDoesNotCrash() {
            let coordinator = AppCoordinator()
            coordinator.dismissSheet()
            #expect(coordinator.sheet == nil)
        }

        @Test func dismissSheetDoesNotAffectFullScreenCover() {
            let coordinator = AppCoordinator()
            coordinator.present(AppFullScreenCover.badge(sampleBadge()))
            coordinator.present(AppSheet.subscription)
            coordinator.dismissSheet()
            #expect(coordinator.fullScreenCover != nil)
        }
    }

    @Suite("fullScreenCover")
    @MainActor
    struct FullScreenCover {
        @Test func presentCoverSetsCover() {
            let coordinator = AppCoordinator()
            coordinator.present(AppFullScreenCover.badge(sampleBadge()))
            #expect(coordinator.fullScreenCover != nil)
        }

        @Test func dismissCoverSetsNil() {
            let coordinator = AppCoordinator()
            coordinator.present(AppFullScreenCover.badge(sampleBadge()))
            coordinator.dismissCover()
            #expect(coordinator.fullScreenCover == nil)
        }

        @Test func dismissCoverDoesNotAffectSheet() {
            let coordinator = AppCoordinator()
            coordinator.present(AppSheet.subscription)
            coordinator.present(AppFullScreenCover.badge(sampleBadge()))
            coordinator.dismissCover()
            #expect(coordinator.sheet != nil)
        }
    }
}
