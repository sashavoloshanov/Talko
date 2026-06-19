import Testing
import Foundation
@testable import Talk

@Suite("SplashState")
@MainActor
struct SplashStateTests {

    @Suite("complete")
    @MainActor
    struct Complete {
        @Test func setsIsFinishedAfterComplete() async {
            let state = SplashState()
            await state.complete(after: .zero) {}
            #expect(state.isFinished)
        }

        @Test func premiumCheckIsCalled() async {
            let state = SplashState()
            var called = false
            await state.complete(after: .zero) { called = true }
            #expect(called)
        }

        @Test func premiumCheckCalledBeforeIsFinished() async {
            let state = SplashState()
            var checkCalledBeforeFinish = false
            await state.complete(after: .zero) {
                checkCalledBeforeFinish = !state.isFinished
            }
            #expect(checkCalledBeforeFinish)
        }

        @Test func isNotFinishedBeforeComplete() async {
            let state = SplashState()
            #expect(!state.isFinished)
        }
    }
}
