import SwiftUI
 
struct SettingsView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LanguageClient.self) private var languageClient
    @Environment(\.languageBundle) private var bundle
    @Environment(ThemeClient.self) private var themeClient
    @Environment(PremiumClient.self) private var premiumClient
    @State private var viewModel = SettingsViewModel()
 
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
 
    var body: some View {
        VStack(spacing: 0) {
            navigationView
            
            List {
                if !premiumClient.isPremium {
                    premiumSection
                }
                
                selectedSection
                
                enteredSection
                
                documentSection
            }
            .scrollContentBackground(.hidden)
 
            versionView
        }
        .background(Colors.backgroundPrimary)
    }
    
    private var navigationView: some View {
        NavigationBar(
            leftButton: nil,
            centerContent: .text(String(localized: "tab_settings", bundle: bundle)),
            rightButton: nil
        )
    }
    
    private var premiumSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Colors.premiumGold)
                    
                    Text(String(localized: "settings_premium_title", bundle: bundle))
                        .font(.headline)
                }
                Text(String(localized: "settings_premium_description", bundle: bundle))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button(String(localized: "settings_premium_button", bundle: bundle)) {
                    coordinator.present(.subscription)
                }
                .buttonStyle(.bordered)
                .foregroundStyle(.white)
                .background(Colors.brandDark)
                .clipShape(.capsule)
                
                
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(Colors.backgroundSecondary)
    }
    
    private var selectedSection: some View {
        Section {
            HStack {
                Text(String(localized: "settings_language", bundle: bundle))
                Spacer()
                Menu {
                    ForEach(AppLanguage.allCases) { lang in
                        Button(lang.displayName) {
                            languageClient.setLanguage(lang)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(languageClient.current.displayName)
                            .foregroundColor(.textSecondary)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack {
                Text(String(localized: "settings_theme", bundle: bundle))
                Spacer()
                Menu {
                    ForEach(AppTheme.allCases) { theme in
                        Button(theme.displayName) {
                            themeClient.setTheme(theme)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(themeClient.current.displayName)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listRowBackground(Colors.backgroundSecondary)
    }
    
    private var enteredSection: some View {
        Section {
            Button(String(localized: "settings_rate", bundle: bundle)) {
                if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") {
                    UIApplication.shared.open(url)
                }
            }
            .foregroundStyle(.textPrimary)
            
            Button(String(localized: "settings_contact", bundle: bundle)) {
                if let url = URL(string: "mailto:voloshanov.developer@icloud.com") {
                    UIApplication.shared.open(url)
                }
            }
            .foregroundStyle(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField(String(localized: "settings_coupon_placeholder", bundle: bundle), text: $viewModel.couponCode)
                    Button(String(localized: "settings_coupon_activate", bundle: bundle)) {
                        viewModel.redeemCoupon(premiumClient: premiumClient, bundle: bundle)
                    }
                    .disabled(viewModel.couponCode.isEmpty || viewModel.isRedeemingCoupon)
                }
                if let msg = viewModel.couponMessage {
                    Text(msg)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .listRowBackground(Colors.backgroundSecondary)
    }
    
    private var documentSection: some View {
        Section {
            Button(String(localized: "settings_privacy", bundle: bundle)) {
                coordinator.present(.document(.privacyPolicy))
            }
            .foregroundStyle(.textPrimary)
            
            Button(String(localized: "settings_terms", bundle: bundle)) {
                coordinator.present(.document(.termsOfService))
            }
            .foregroundStyle(.textPrimary)
        }
        .listRowBackground(Colors.backgroundSecondary)
    }
    
    private var versionView: some View {
        Text("Version: \(appVersion)")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.vertical, 8)
            .padding(.bottom, 8)
    }
}

#if DEBUG
#Preview("Dark") {
    PreviewContainer(scheme: .dark) { SettingsView() }
}

#Preview("Light") {
    PreviewContainer(scheme: .light) { SettingsView() }
}
#endif
