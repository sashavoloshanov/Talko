import SwiftUI
import WidgetKit
import AppIntents

struct LargeWidgetView: View {
    let entry: CategoryEntry

    var canGoPrev: Bool { entry.currentIndex > 1 }
    var canGoNext: Bool { entry.currentIndex < entry.totalCount }

    var body: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 8) {
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                Text("\(entry.categoryEmoji) \(entry.categoryName)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(entry.currentIndex) / \(entry.totalCount)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.background.secondary)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)

                Text(entry.questionText)
                    .font(.callout.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(24)
            }

            Spacer()
            
            HStack(spacing: 12) {
                Button(intent: PrevQuestionIntent(categoryId: entry.categoryId)) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(.background.secondary)
                        .clipShape(Capsule())
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                .opacity(canGoPrev ? 1 : 0.3)

                Button(intent: NextQuestionIntent(categoryId: entry.categoryId)) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(.background.secondary)
                        .clipShape(Capsule())
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                .opacity(canGoNext ? 1 : 0.3)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
