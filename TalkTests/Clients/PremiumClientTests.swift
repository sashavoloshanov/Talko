import Testing
import Foundation
@testable import Talk

@Suite("PremiumClient", .serialized)
@MainActor
struct PremiumClientTests {

    @Suite("init")
    @MainActor
    struct Init {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.premium.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func noSavedPremium_defaultsToFalse() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let client = PremiumClient()
            #expect(client.isPremium == false)
        }

        @Test func savedPremiumTrue_restoresTrue() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(true, for: .isPremium)
            UserDefaultsClient.defaults = defaults
            let client = PremiumClient()
            #expect(client.isPremium == true)
        }

        @Test func initialProducts_isEmpty() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let client = PremiumClient()
            #expect(client.products.isEmpty)
        }

        @Test func initialLastPurchaseError_isNil() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let client = PremiumClient()
            #expect(client.lastPurchaseError == nil)
        }
    }

    @Suite("redeemCoupon")
    @MainActor
    struct RedeemCoupon {
        @Test func emptyCode_throwsCouponInvalid() async {
            let client = PremiumClient()
            await #expect(throws: (any Error).self) {
                try await client.redeemCoupon("")
            }
        }

        @Test func nonEmptyCode_doesNotThrow() async throws {
            let client = PremiumClient()
            try await client.redeemCoupon("VALID123")
        }

        @Test func whitespaceOnlyCode_doesNotThrow() async {
            let client = PremiumClient()
            // Guard only checks isEmpty, so whitespace is accepted — document current behaviour
            var didThrow = false
            do { try await client.redeemCoupon("   ") }
            catch { didThrow = true }
            #expect(didThrow == false)
        }
    }

    @Suite("CouponError")
    @MainActor
    struct CouponErrorTests {
        @Test func invalidErrorDescription() {
            let error = PremiumClient.CouponError.invalid
            #expect(error.errorDescription == "Invalid coupon code")
        }
    }

    @Suite("product IDs")
    @MainActor
    struct ProductIDs {
        @Test func monthlyProductIDIsCorrect() {
            #expect(PremiumClient.monthlyProductID == "com.talkapp.premium.monthly")
        }

        @Test func annualProductIDIsCorrect() {
            #expect(PremiumClient.annualProductID == "com.talkapp.premium.annual")
        }
    }
}
