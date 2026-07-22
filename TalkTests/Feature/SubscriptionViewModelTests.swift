import Testing
import Foundation
import StoreKit
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

    @Suite("loadProducts")
    @MainActor
    struct LoadProducts {
        @Test func withoutSetup_isNoOp() async {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            await vm.loadProducts()
            #expect(vm.products.isEmpty)
            #expect(vm.selectedProductId == nil)
        }

        @Test func afterLoad_stateIsConsistentWithClient() async {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.setup(premiumClient: premium)
            await vm.loadProducts()
            #expect(vm.isLoading == false)
            #expect(vm.products.map(\.id) == premium.products.map(\.id))
            if vm.products.isEmpty {
                #expect(vm.selectedProductId == nil)
            } else {
                let expected = vm.products.first(where: { $0.id == PremiumClient.annualProductID })?.id
                    ?? vm.products.first?.id
                #expect(vm.selectedProductId == expected)
            }
        }

        @Test func doesNotCrashOnMultipleCalls() async {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.setup(premiumClient: premium)
            vm.setup(premiumClient: premium)
            await vm.loadProducts()
            await vm.loadProducts()
            #expect(vm.isLoading == false)
        }
    }

    @Suite("purchase")
    @MainActor
    struct Purchase {
        @Test func withoutSetup_isNoOp() async {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            vm.selectedProductId = PremiumClient.monthlyProductID
            await vm.purchase()
            #expect(vm.isLoading == false)
            #expect(vm.purchaseError == nil)
        }

        @Test func noSelectedProduct_isNoOp() async {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.setup(premiumClient: premium)
            await vm.purchase()
            #expect(vm.isLoading == false)
            #expect(vm.purchaseError == nil)
        }

        @Test func withSelectedProductId_noProductsInClient_purchaseSuccessFalse() async {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.setup(premiumClient: premium)
            vm.selectedProductId = PremiumClient.monthlyProductID
            await vm.purchase()
            #expect(vm.isLoading == false)
            #expect(vm.purchaseSuccess == false)
        }

        @Test func withSelectedProductId_noProductsInClient_purchaseErrorNil() async {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            vm.setup(premiumClient: premium)
            vm.selectedProductId = PremiumClient.annualProductID
            await vm.purchase()
            #expect(vm.purchaseError == nil)
        }
    }

    @Suite("restorePurchases")
    @MainActor
    struct RestorePurchases {
        // restorePurchases() with an injected client calls the real AppStore.sync(),
        // which can block on a sign-in prompt in the simulator — only the
        // dependency guard is testable deterministically.
        @Test func withoutSetup_isNoOp() async {
            let (defaults, suite) = makeDefaults()
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            await vm.restorePurchases()
            #expect(vm.isLoading == false)
            #expect(vm.purchaseSuccess == false)
        }
    }
}
