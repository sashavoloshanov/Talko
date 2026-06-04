import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(PremiumClient.self) private var premiumClient
    @Environment(\.languageBundle) private var bundle
    @State private var viewModel = SubscriptionViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        coordinator.dismissSheet()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Colors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Colors.premiumGold)
                        .padding(.top, 24)
                    
                    Text(String(localized: "subscription_title", bundle: bundle))
                        .font(.title.bold())
                        .foregroundColor(Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(String(localized: "subscription_subtitle", bundle: bundle))
                        .font(.subheadline)
                        .foregroundColor(Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer().frame(height: 32)
                
                if viewModel.isLoading && viewModel.products.isEmpty {
                    ProgressView()
                        .tint(Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.products, id: \.id) { product in
                            SubscriptionPlanCard(
                                product: product,
                                isSelected: viewModel.selectedProductId == product.id,
                                bundle: bundle,
                                onTap: { viewModel.selectedProductId = product.id }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                if let error = viewModel.purchaseError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.9))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }
                
                Button {
                    viewModel.purchase(premiumClient: premiumClient)
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView().tint(Colors.brandDark)
                        } else {
                            Text(String(localized: "subscription_cta", bundle: bundle))
                                .font(.headline)
                                .foregroundColor(Colors.brandDark)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                }
                .background(Colors.premiumGold)
                .clipShape(Capsule())
                .padding(.horizontal, 20)
                .disabled(viewModel.isLoading || viewModel.selectedProductId == nil)
                
                Button {
                    viewModel.restorePurchases(premiumClient: premiumClient)
                } label: {
                    Text(String(localized: "subscription_restore", bundle: bundle))
                        .font(.footnote)
                        .foregroundColor(Colors.textSecondary)
                }
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .background(Colors.backgroundPrimary)
        .onAppear {
            viewModel.setup(premiumClient: premiumClient)
        }
        .onChange(of: viewModel.purchaseSuccess) { _, success in
            if success { coordinator.dismissSheet() }
        }
    }
}

private struct SubscriptionPlanCard: View {
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
