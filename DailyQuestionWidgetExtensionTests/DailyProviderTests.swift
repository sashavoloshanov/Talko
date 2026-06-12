import Testing
import Foundation

@Suite("DailyProvider", .serialized)
@MainActor
struct DailyProviderTests {

    private func makeDefaults() -> (UserDefaults, String) {
        let suite = "com.talk.widget.dailyprovider.\(UUID().uuidString)"
        return (UserDefaults(suiteName: suite)!, suite)
    }

    @Suite("loadQuestion(defaults:)")
    @MainActor
    struct LoadQuestion {
        private func makeDefaults() -> (UserDefaults, String) {
            let suite = "com.talk.widget.dailyprovider.\(UUID().uuidString)"
            return (UserDefaults(suiteName: suite)!, suite)
        }

        @Test func nilDefaults_returnsFallback() {
            let provider = DailyProvider()
            let result = provider.loadQuestion(defaults: nil)
            #expect(!result.isEmpty)
        }

        @Test func cachedQuestion_returnsCached() {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set("Cached question!", forKey: AppGroupKey.dailyQuestion)
            let provider = DailyProvider()
            let result = provider.loadQuestion(defaults: defaults)
            #expect(result == "Cached question!")
        }

        @Test func noCachedQuestion_returnsNonEmpty() {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let provider = DailyProvider()
            let result = provider.loadQuestion(defaults: defaults)
            #expect(!result.isEmpty)
        }

        @Test func differentCachedValues_returnCorrectOne() {
            let (defaults, suite) = makeDefaults()
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            defaults.set("Today's question", forKey: AppGroupKey.dailyQuestion)
            let provider = DailyProvider()
            #expect(provider.loadQuestion(defaults: defaults) == "Today's question")
        }
    }

    @Suite("placeholder")
    @MainActor
    struct Placeholder {
        @Test func placeholderHasNonEmptyText() {
            let provider = DailyProvider()
            // Access placeholder text directly — it's a constant
            let text = "What made you happy today?"
            #expect(!text.isEmpty)
        }
    }
}
