import SwiftUI

struct SplashView: View {
    var state: SplashState
    
    @State private var textScale: CGFloat = 0.3
    @State private var textOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.8
    @State private var iconOpacity: Double = 0
    
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
                
                Text("Talk")
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                state.isFinished = true
            }
        }
    }
}

#Preview {
    SplashView(state: SplashState())
}
