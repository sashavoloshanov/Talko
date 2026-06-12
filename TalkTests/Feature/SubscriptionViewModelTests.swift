import Testing
import Foundation
@testable import Talk

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

    @Suite("purchase")
    @MainActor
    struct Purchase {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.subscription.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func noSelectedProduct_isNoOp() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SubscriptionViewModel()
            let premium = PremiumClient()
            // selectedProductId is nil — guard returns early, no Task started
            vm.purchase(premiumClient: premium)
            #expect(vm.isLoading == false)
            #expect(vm.purchaseError == nil)
        }
    }
}
