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

        @Test func withoutSetup_isNoOp() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SettingsViewModel()
            vm.couponCode = "TESTCODE"
            await vm.redeemCoupon(bundle: .main)
            #expect(vm.isRedeemingCoupon == false)
            #expect(vm.couponMessage == nil)
        }

        @Test func validCode_setsSuccessMessageAndStopsRedeeming() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SettingsViewModel()
            let premium = PremiumClient()
            vm.setup(premiumClient: premium)
            vm.couponCode = "TESTCODE"
            await vm.redeemCoupon(bundle: .main)
            #expect(vm.isRedeemingCoupon == false)
            #expect(vm.couponMessage != nil)
            #expect(premium.isPremium == true)
        }

        @Test func emptyCode_setsErrorMessage() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = SettingsViewModel()
            let premium = PremiumClient()
            vm.setup(premiumClient: premium)
            vm.couponCode = ""
            await vm.redeemCoupon(bundle: .main)
            #expect(vm.isRedeemingCoupon == false)
            #expect(vm.couponMessage == "Invalid coupon code")
            #expect(premium.isPremium == false)
        }
    }
}
