import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(PremiumClient.self) private var premiumClient
    @Environment(LanguageClient.self) private var languageClient
    @Environment(\.languageBundle) private var bundle
    @Environment(\.openURL) private var openURL
    @State private var viewModel = SubscriptionViewModel()

    private var privacyPolicyURL: URL {
        let suffix = languageClient.current == .ukrainian ? "privacy_policy_ua" : "privacy_policy_en"
        return URL(string: "https://sashavoloshanov.github.io/Talko/\(suffix)")!
    }

    private var termsOfUseURL: URL {
        let suffix = languageClient.current == .ukrainian ? "terms_of_use_ua" : "terms_of_use_en"
        return URL(string: "https://sashavoloshanov.github.io/Talko/\(suffix)")!
    }
    
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
                    Task { await viewModel.purchase() }
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
                    Task { await viewModel.restorePurchases() }
                } label: {
                    Text(String(localized: "subscription_restore", bundle: bundle))
                        .font(.footnote)
                        .foregroundColor(Colors.textSecondary)
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
                
                HStack(spacing: 16) {
                    Button {
                        openURL(privacyPolicyURL)
                    } label: {
                        Text(String(localized: "settings_privacy", bundle: bundle))
                            .font(.caption2)
                            .foregroundColor(Colors.textSecondary)
                    }
                    Button {
                        openURL(termsOfUseURL)
                    } label: {
                        Text(String(localized: "settings_terms", bundle: bundle))
                            .font(.caption2)
                            .foregroundColor(Colors.textSecondary)
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .background(Colors.backgroundPrimary)
        .task {
            viewModel.setup(premiumClient: premiumClient)
            await viewModel.loadProducts()
        }
        .onChange(of: viewModel.purchaseSuccess) { _, success in
            if success { coordinator.dismissSheet() }
        }
    }
}
