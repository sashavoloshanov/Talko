import SwiftUI

struct QuestionCardView: View {
    let text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Colors.backgroundSecondary)
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)

            Text(text)
                .font(.title3.weight(.medium))
                .foregroundColor(Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(32)
        }
        .frame(maxWidth: .infinity)
    }
}
