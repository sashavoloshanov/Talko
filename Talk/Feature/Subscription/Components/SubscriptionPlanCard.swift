import SwiftUI
import StoreKit

struct SubscriptionPlanCard: View {
    let product: Product
    let isSelected: Bool
    let bundle: Bundle
    let onTap: () -> Void

    private var isAnnual: Bool { product.id == PremiumClient.annualProductID }

    private var periodText: String {
        guard let period = product.subscription?.subscriptionPeriod else { return "" }
        return "/ \(unitText(for: period))"
    }

    private var trialText: String? {
        guard let offer = product.subscription?.introductoryOffer,
              offer.paymentMode == .freeTrial else { return nil }
        return trialText(for: offer.period)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(product.displayName)
                            .font(.headline)
                            .foregroundColor(Colors.textPrimary)
                        if isAnnual {
                            Text(String(localized: "subscription_savings", bundle: bundle))
                                .font(.caption.bold())
                                .foregroundColor(Colors.brandDark)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Colors.premiumGold))
                        }
                    }
                    if let trialText {
                        Text(trialText)
                            .font(.subheadline)
                            .foregroundColor(Colors.textSecondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.title3.bold())
                        .foregroundColor(Colors.textPrimary)
                    Text(periodText)
                        .font(.caption)
                        .foregroundColor(Colors.textSecondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Colors.backgroundElevated : Colors.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? Colors.premiumGold : Color.clear,
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func unitText(for period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:
            return String(localized: "period_day", defaultValue: "\(period.value) days", bundle: bundle)
        case .week:
            return String(localized: "period_week", defaultValue: "\(period.value) weeks", bundle: bundle)
        case .month:
            return String(localized: "period_month", defaultValue: "\(period.value) months", bundle: bundle)
        case .year:
            return String(localized: "period_year", defaultValue: "\(period.value) years", bundle: bundle)
        @unknown default:
            return ""
        }
    }

    private func trialText(for period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:
            return String(localized: "trial_day", defaultValue: "\(period.value)-day free trial", bundle: bundle)
        case .week:
            return String(localized: "trial_week", defaultValue: "\(period.value)-week free trial", bundle: bundle)
        case .month:
            return String(localized: "trial_month", defaultValue: "\(period.value)-month free trial", bundle: bundle)
        case .year:
            return String(localized: "trial_year", defaultValue: "\(period.value)-year free trial", bundle: bundle)
        @unknown default:
            return ""
        }
    }
}
