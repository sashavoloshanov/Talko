import SwiftUI

struct BadgeDetailView: View {
    @Environment(AppCoordinator.self) private var coordinator
    let badge: Badge

    @State private var shareImage: UIImage?
    @State private var isSharePresented = false

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

            if badge.isEarned, shareImage != nil {
                shareButton
            }
        }
        .task {
            guard badge.isEarned else { return }
            shareImage = try? await BadgeImageClient.shared.image(named: badge.imageName)
        }
        .sheet(isPresented: $isSharePresented) {
            if let shareImage {
                ActivityShareSheet(items: [shareImage])
                    .presentationDetents([.medium, .large])
            }
        }
    }

    @ViewBuilder
    private var badgeView: some View {
        if badge.isEarned {
            RemoteBadgeImage(imageName: badge.imageName)
                .padding(32)
        } else {
            VStack(alignment: .center, spacing: 24) {
                Image("lockedBadgeIcon")
                    .resizable()
                    .scaledToFit()

                Text("\(min(badge.progress, badge.threshold)) / \(badge.threshold)")
                    .font(.title2.bold())
                    .foregroundColor(Colors.textPrimary)
            }
            .padding(32)
        }
    }

    private var shareButton: some View {
        Button {
            isSharePresented = true
        } label: {
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

// UIActivityViewController shares a plain UIImage, which every social app
// accepts — ShareLink's Transferable items arrive empty in some targets.
private struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
