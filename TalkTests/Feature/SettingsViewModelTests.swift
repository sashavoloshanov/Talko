import Testing
import Foundation
@testable import Talk

@Suite("SettingsViewModel", .serialized)
@MainActor
struct SettingsViewModelTests {

    @Suite("initial state")
    @MainActor
    struct InitialState {
        @Test func defaultValues() {
            let vm = SettingsViewModel()
            #expect(vm.couponCode == "")
            #expect(vm.couponMessage == nil)
            #expect(vm.isRedeemingCoupon == false)
            #expect(vm.isLoading == false)
            #expect(vm.errorMessage == nil)
        }
    }

    @Suite("redeemCoupon")
    @MainActor
    struct RedeemCoupon {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.settings.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func immediatelyAfterCall_isRedeemingCoupon_isTrue() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SettingsViewModel()
            let premium = PremiumClient()
            vm.setup(premiumClient: premium)
            vm.couponCode = "TESTCODE"
            vm.redeemCoupon(bundle: .main)
            #expect(vm.isRedeemingCoupon == true)
        }

        @Test func immediatelyAfterCall_clearsMessage() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SettingsViewModel()
            let premium = PremiumClient()
            vm.setup(premiumClient: premium)
            vm.couponMessage = "old message"
            vm.couponCode = "CODE"
            vm.redeemCoupon(bundle: .main)
            #expect(vm.couponMessage == nil)
        }

    }
}
