import Foundation
import Observation

@Observable
final class SettingsViewModel: BaseViewModel {
    var couponCode: String = ""
    var couponMessage: String? = nil
    var isRedeemingCoupon: Bool = false

    @ObservationIgnored private var premiumClient: PremiumClient?

    func setup(premiumClient: PremiumClient) {
        self.premiumClient = premiumClient
    }

    func redeemCoupon(bundle: Bundle) async {
        guard let premiumClient else { return }
        await MainActor.run {
            isRedeemingCoupon = true
            couponMessage = nil
        }
        do {
            try await premiumClient.redeemCoupon(couponCode)
            await MainActor.run {
                premiumClient.isPremium = true
                couponMessage = String(localized: "settings_coupon_success", bundle: bundle)
                isRedeemingCoupon = false
            }
        } catch {
            await MainActor.run {
                couponMessage = error.localizedDescription
                isRedeemingCoupon = false
            }
        }
    }
}
