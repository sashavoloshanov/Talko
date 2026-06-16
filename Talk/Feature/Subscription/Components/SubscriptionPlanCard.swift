import SwiftUI
import StoreKit

struct SubscriptionPlanCard: View {
    let product: Product
    let isSelected: Bool
    let bundle: Bundle
    let onTap: () -> Void
    
    private var isAnnual: Bool { product.id == PremiumClient.annualProductID }
    private var trialText: String { isAnnual ? "7-day free trial" : "3-day free trial" }
    private var periodText: String { isAnnual ? "/ year" : "/ month" }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
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
                    Text(trialText)
                        .font(.subheadline)
                        .foregroundColor(Colors.textSecondary)
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
}
