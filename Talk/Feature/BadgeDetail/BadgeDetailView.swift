import SwiftUI
import UniformTypeIdentifiers

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
            .frame(maxWidth: .infinity)
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
            VStack(alignment: .center, spacing: 16) {
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
            item: BadgeShareItem(image: image, fileName: badge.imageName),
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

// Shared as a PNG file so every target app (messengers, social, Files)
// accepts it — SwiftUI Image lacks a file representation for some apps.
private struct BadgeShareItem: Transferable {
    let image: UIImage
    let fileName: String

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .png) { item in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(item.fileName)
                .appendingPathExtension("png")
            guard let data = item.image.pngData() else {
                throw CocoaError(.fileWriteUnknown)
            }
            try data.write(to: url)
            return SentTransferredFile(url)
        }
    }
}
