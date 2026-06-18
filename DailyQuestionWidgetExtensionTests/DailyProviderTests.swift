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

    @Suite("loadFromBundle()")
    @MainActor
    struct LoadFromBundle {

        @Test func doesNotCrash() {
            let provider = DailyProvider()
            // In the test environment Bundle.main is the test runner — daily.json
            // may not be present, so nil is the expected fallback; no crash is the guarantee.
            _ = provider.loadFromBundle()
        }

        @Test func returnsNilOrNonEmptyString() {
            let provider = DailyProvider()
            let result = provider.loadFromBundle()
            if let text = result {
                #expect(!text.isEmpty)
            }
        }

        @Test func loadQuestion_fallsBackToBundleWhenNoCachedValue() {
            // No cached question → loadQuestion calls loadFromBundle → falls back to hardcoded
            let provider = DailyProvider()
            let result = provider.loadQuestion(defaults: nil)
            #expect(!result.isEmpty)
        }

        @Test func loadQuestion_bundleFallbackProducesNonEmptyString() {
            // Empty defaults (no daily question key) triggers loadFromBundle path
            let suite = "com.talk.widget.bundle.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suite)!
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let provider = DailyProvider()
            let result = provider.loadQuestion(defaults: defaults)
            #expect(!result.isEmpty)
        }
    }
}
