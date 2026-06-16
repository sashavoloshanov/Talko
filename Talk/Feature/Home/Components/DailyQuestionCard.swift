import SwiftUI

struct DailyQuestionCard: View {
    let question: DailyQuestion

    var body: some View {
        HStack(spacing: 16) {
            Text(question.text)
                .font(.body)
                .foregroundColor(Colors.textPrimary)
                .multilineTextAlignment(.leading)

            Spacer()
            
            HStack {
                ShareLink(item: shareText(for: question)) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Colors.textPrimary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Colors.backgroundSecondary)
        )
    }
    
    private func shareText(for question: DailyQuestion) -> String {
        """
        \(question.text)

        By Talko
        https://apps.apple.com/app/idYOUR_APP_ID
        """
    }
}
