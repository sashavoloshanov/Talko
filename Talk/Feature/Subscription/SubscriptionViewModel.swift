import Foundation
import Observation
import StoreKit

@Observable
final class SubscriptionViewModel: BaseViewModel {
    var products: [Product] = []
    var selectedProductId: String? = nil
    var purchaseSuccess: Bool = false
    var purchaseError: String? = nil

    func setup(premiumClient: PremiumClient) {
        Task { await loadProducts(premiumClient: premiumClient) }
    }

    private func loadProducts(premiumClient: PremiumClient) async {
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

    func purchase(premiumClient: PremiumClient) {
        guard let id = selectedProductId else { return }
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

    func restorePurchases(premiumClient: PremiumClient) {
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
