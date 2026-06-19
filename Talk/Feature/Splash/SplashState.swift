import Observation

@Observable
class SplashState {
    var isFinished = false

    func complete(after duration: Duration = .seconds(1.5), premiumCheck: () async -> Void) async {
        try? await Task.sleep(for: duration)
        guard !Task.isCancelled else { return }
        await premiumCheck()
        isFinished = true
    }
}
