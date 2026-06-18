import Testing
import Foundation
@testable import Talk

private func makeDefaults() -> (UserDefaults, String) {
    let suite = "com.talk.tests.subscription.\(UUID().uuidString)"
    return (UserDefaults(suiteName: suite)!, suite)
}

@Suite("SubscriptionViewModel", .serialized)
@MainActor
struct SubscriptionViewModelTests {

    @Suite("initial state")
    @MainActor
    struct InitialState {
        @Test func defaultValues() {
            let vm = SubscriptionViewModel()
            #expect(vm.products.isEmpty)
            #expect(vm.selectedProductId == nil)
            #expect(vm.purchaseSuccess == false)
            #expect(vm.purchaseError == nil)
            #expect(vm.isLoading == false)
            #expect(vm.errorMessage == nil)
        }
    }

    @Suite("setup")
    @MainActor
    struct Setup {
        @Test func setup_withEmptyStoreKit_productsRemainsEmpty() async throws {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.setup(premiumClient: premium)
            try await Task.sleep(nanoseconds: 200_000_000)
            #expect(vm.products.isEmpty)
        }

        @Test func setup_withEmptyStoreKit_selectedProductIdRemainsNil() async throws {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.setup(premiumClient: premium)
            try await Task.sleep(nanoseconds: 200_000_000)
            #expect(vm.selectedProductId == nil)
        }

        @Test func setup_doesNotCrashOnMultipleCalls() async throws {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.setup(premiumClient: premium)
            vm.setup(premiumClient: premium)
            try await Task.sleep(nanoseconds: 200_000_000)
            #expect(vm.products.isEmpty)
        }
    }

    @Suite("purchase")
    @MainActor
    struct Purchase {
        @Test func noSelectedProduct_isNoOp() {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.purchase(premiumClient: premium)
            #expect(vm.isLoading == false)
            #expect(vm.purchaseError == nil)
        }

        @Test func withSelectedProductId_noProductsInClient_purchaseSuccessFalse() async throws {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.selectedProductId = PremiumClient.monthlyProductID
            vm.purchase(premiumClient: premium)
            try await Task.sleep(nanoseconds: 200_000_000)
            #expect(vm.isLoading == false)
            #expect(vm.purchaseSuccess == false)
        }

        @Test func withSelectedProductId_noProductsInClient_purchaseErrorNil() async throws {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.selectedProductId = PremiumClient.annualProductID
            vm.purchase(premiumClient: premium)
            try await Task.sleep(nanoseconds: 200_000_000)
            #expect(vm.purchaseError == nil)
        }
    }

    @Suite("restorePurchases")
    @MainActor
    struct RestorePurchases {
        @Test func doesNotCrashOnMultipleCalls() async throws {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.restorePurchases(premiumClient: premium)
            vm.restorePurchases(premiumClient: premium)
            try await Task.sleep(nanoseconds: 300_000_000)
            #expect(vm.purchaseSuccess == premium.isPremium)
        }

        @Test func withoutActiveEntitlement_purchaseSuccessRemainsDefault() async throws {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.restorePurchases(premiumClient: premium)
            try await Task.sleep(nanoseconds: 300_000_000)
            #expect(vm.purchaseSuccess == premium.isPremium)
        }
    }
}
