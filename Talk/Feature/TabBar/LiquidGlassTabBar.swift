import SwiftUI
 
struct LiquidGlassTabBar: View {
    @Binding var selectedTab: AppTab
 
    private let barHeight: CGFloat = 64
    private let inset: CGFloat = 4
    private let bottomPadding: CGFloat = 12
 
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    inset: inset
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: barHeight)
        .padding(inset)
        .background(GlassBackground())
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.45),
                            .white.opacity(0.1),
                            .clear,
                            .white.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
        )
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 24)
        .padding(.bottom, bottomPadding + UIApplication.safeAreaBottomInset)
    }
}
 
struct GlassBackground: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.12),
                            .white.opacity(0.04)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }
}
 
struct TabBarItem: View {
    @Environment(\.languageBundle) private var bundle
    let tab: AppTab
    let isSelected: Bool
    let inset: CGFloat
    let action: () -> Void
 
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Capsule()
                        .fill(.textPrimary.opacity(0.18))
                        .overlay(
                            Capsule()
                                .strokeBorder(.white.opacity(0.3), lineWidth: 0.5)
                        )
                        .transition(.scale.combined(with: .opacity))
                }
 
                HStack(spacing: 6) {
                    Image(tab.icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .tint(Color.textPrimary)
                        .frame(width: isSelected ? 36 : 26,
                               height: isSelected ? 36 : 26)
                }
                .foregroundStyle(isSelected ? Color.textPrimary : Color.textPrimary.opacity(0.5))
                .padding(.horizontal, isSelected ? 14 : 0)
            }
            .frame(maxHeight: .infinity)
        }
        .buttonStyle(TabButtonStyle())
    }
}
 
struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
