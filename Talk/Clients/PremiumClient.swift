import Foundation
import Observation
import StoreKit
import WidgetKit

@Observable
final class PremiumClient {

    static let monthlyProductID = "com.voloshanov.talko.premium.monthly"
    static let annualProductID  = "com.voloshanov.talko.premium.annual"
    private static let allProductIDs: Set<String> = [monthlyProductID, annualProductID]

    var isPremium: Bool {
        didSet {
            appGroupDefaults?.set(isPremium, forKey: AppGroupKey.isPremium)
            widgetCenter.reloadAllTimelines()
            refreshWidgetQuestions()
        }
    }
    var products: [Product] = []
    var lastPurchaseError: String? = nil

    private let appGroupDefaults: UserDefaults?
    private let widgetCenter: any WidgetCenterProtocol
    private let questionClient: any QuestionClientProtocol
    private var transactionListenerTask: Task<Void, Never>?

    init(
        appGroupDefaults: UserDefaults? = UserDefaults(suiteName: AppGroupKey.suiteName),
        widgetCenter: any WidgetCenterProtocol = WidgetCenter.shared,
        questionClient: any QuestionClientProtocol = QuestionClient.shared
    ) {
        self.appGroupDefaults = appGroupDefaults
        self.widgetCenter = widgetCenter
        self.questionClient = questionClient
        self.isPremium = appGroupDefaults?.bool(forKey: AppGroupKey.isPremium) ?? false
        transactionListenerTask = listenForTransactions()
    }

    // Category widgets cache a premium-filtered question pool in the App Group,
    // so a premium change must rebuild that pool, not just re-render timelines.
    private func refreshWidgetQuestions() {
        let language = AppLanguage(rawValue: appGroupDefaults?.string(forKey: AppGroupKey.appLanguage) ?? "") ?? .ukrainian
        Task { [questionClient] in
            await questionClient.refreshWidgetData(for: language)
        }
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await MainActor.run { self.isPremium = true }
                    await transaction.finish()
                }
            }
        }
    }

    func checkPremiumStatus() async {
        let hasActive = await hasActiveEntitlement()
        await MainActor.run { isPremium = hasActive }
    }

    private func hasActiveEntitlement() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               Self.allProductIDs.contains(tx.productID),
               tx.revocationDate == nil {
                return true
            }
        }
        return false
    }

    func fetchAvailableProducts() async {
        do {
            let fetched = try await Product.products(for: Self.allProductIDs)
            await MainActor.run {
                self.products = fetched.sorted {
                    $0.id == Self.monthlyProductID && $1.id != Self.monthlyProductID
                }
                if fetched.isEmpty {
                    self.lastPurchaseError = "No products returned by the App Store."
                }
            }
        } catch {
            await MainActor.run { self.lastPurchaseError = error.localizedDescription }
        }
    }

    func purchase(_ productId: String) async {
        guard let product = products.first(where: { $0.id == productId }) else { return }
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result,
               case .verified(let tx) = verification {
                await MainActor.run { isPremium = true; lastPurchaseError = nil }
                await tx.finish()
            }
        } catch {
            await MainActor.run { lastPurchaseError = error.localizedDescription }
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            let hasActive = await hasActiveEntitlement()
            await MainActor.run { isPremium = hasActive }
        } catch {
            await MainActor.run { lastPurchaseError = error.localizedDescription }
        }
    }

    func redeemCoupon(_ code: String) async throws {
        guard !code.isEmpty else { throw CouponError.invalid }
    }

    enum CouponError: LocalizedError {
        case invalid
        var errorDescription: String? { "Invalid coupon code" }
    }
}
