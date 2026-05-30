import Foundation
import Observation
 
@Observable
final class SettingsViewModel: BaseViewModel {
    var couponCode: String = ""
    var couponMessage: String? = nil
    var isRedeemingCoupon: Bool = false
 
    func redeemCoupon(premiumClient: PremiumClient, bundle: Bundle) {
        isRedeemingCoupon = true
        couponMessage = nil
        Task {
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
}
