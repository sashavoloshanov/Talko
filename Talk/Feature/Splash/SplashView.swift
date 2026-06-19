import SwiftUI

struct SplashView: View {
    var state: SplashState

    @Environment(PremiumClient.self) private var premiumClient
    @State private var textScale: CGFloat = 0.3
    @State private var textOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.8
    @State private var iconOpacity: Double = 0
    @State private var splashTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Colors.brandDark
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image("logoIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 54)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)

                Text("Talko")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(textScale)
                    .opacity(textOpacity)
            }
            .offset(y: -42)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.5)) {
                textScale = 1.0
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.5)) {
                textOpacity = 1.0
            }
            let client = premiumClient
            splashTask = Task {
                await state.complete { await client.checkPremiumStatus() }
            }
        }
        .onDisappear {
            splashTask?.cancel()
            splashTask = nil
        }
    }
}

#if DEBUG
#Preview("Dark") {
    PreviewContainer(scheme: .dark) { SplashView(state: SplashState()) }
}

#Preview("Light") {
    PreviewContainer(scheme: .light) { SplashView(state: SplashState()) }
}
#endif
