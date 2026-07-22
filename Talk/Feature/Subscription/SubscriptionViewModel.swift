import Foundation
import Observation
import StoreKit

@Observable
final class SubscriptionViewModel: BaseViewModel {
    var products: [Product] = []
    var selectedProductId: String? = nil
    var purchaseSuccess: Bool = false
    var purchaseError: String? = nil

    @ObservationIgnored private var premiumClient: PremiumClient?

    func setup(premiumClient: PremiumClient) {
        self.premiumClient = premiumClient
    }

    func loadProducts() async {
        guard let premiumClient else { return }
        await MainActor.run { isLoading = true }
        await premiumClient.fetchAvailableProducts()
        await MainActor.run {
            self.products = premiumClient.products
            self.selectedProductId = premiumClient.products
                .first(where: { $0.id == PremiumClient.annualProductID })?.id
                ?? premiumClient.products.first?.id
            isLoading = false
        }
    }

    func purchase() {
        guard let premiumClient, let id = selectedProductId else { return }
        Task {
            await MainActor.run { isLoading = true; purchaseError = nil }
            await premiumClient.purchase(id)
            await MainActor.run {
                isLoading = false
                purchaseSuccess = premiumClient.isPremium
                if !premiumClient.isPremium {
                    purchaseError = premiumClient.lastPurchaseError
                }
            }
        }
    }

    func restorePurchases() {
        guard let premiumClient else { return }
        Task {
            await MainActor.run { isLoading = true; purchaseError = nil }
            await premiumClient.restorePurchases()
            await MainActor.run {
                isLoading = false
                purchaseSuccess = premiumClient.isPremium
            }
        }
    }
}
