import SwiftUI

struct BadgeDetailView: View {
    @Environment(AppCoordinator.self) private var coordinator
    let badge: Badge

    @State private var shareImage: UIImage?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.white.opacity(0.4)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture { coordinator.dismissCover() }

            VStack {
                Spacer()

                badgeView

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture { coordinator.dismissCover() }

            if badge.isEarned, let shareImage {
                shareButton(shareImage)
            }
        }
        .task {
            guard badge.isEarned else { return }
            shareImage = try? await BadgeImageClient.shared.image(named: badge.imageName)
        }
    }

    @ViewBuilder
    private var badgeView: some View {
        if badge.isEarned {
            RemoteBadgeImage(imageName: badge.imageName)
                .padding(32)
        } else {
            VStack(spacing: 16) {
                Image("lockedBadgeIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160)

                Text("\(min(badge.progress, badge.threshold)) / \(badge.threshold)")
                    .font(.title2.bold())
                    .foregroundColor(Colors.textPrimary)
            }
            .padding(32)
        }
    }

    private func shareButton(_ image: UIImage) -> some View {
        ShareLink(
            item: Image(uiImage: image),
            preview: SharePreview(badge.name, image: Image(uiImage: image))
        ) {
            ZStack {
                Circle()
                    .frame(width: 44, height: 44)
                    .foregroundColor(Colors.textPrimary)

                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Colors.backgroundSecondary)
                    .offset(y: -1)
            }
        }
        .padding(.top, 20)
        .padding(.trailing, 20)
    }
}
