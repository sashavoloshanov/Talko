import SwiftUI

struct RemoteBadgeImage: View {
    let imageName: String

    @State private var loadState: LoadState = .loading

    var body: some View {
        Group {
            switch loadState {
            case .loading:
                ProgressView()
            case .loaded(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            case .failed:
                Image("lockedBadgeIcon")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.4)
            }
        }
        .task(id: imageName) {
            await load()
        }
        .onAppear {
            if case .failed = loadState {
                Task { await load() }
            }
        }
    }

    private func load() async {
        loadState = .loading
        do {
            let image = try await BadgeImageClient.shared.image(named: imageName)
            loadState = .loaded(image)
        } catch {
            loadState = .failed
        }
    }

    private enum LoadState {
        case loading
        case loaded(UIImage)
        case failed
    }
}

#if DEBUG
#Preview("Dark") {
    PreviewContainer(scheme: .dark) {
        RemoteBadgeImage(imageName: "badge_couple_1")
            .frame(width: 80, height: 80)
    }
}

#Preview("Light") {
    PreviewContainer(scheme: .light) {
        RemoteBadgeImage(imageName: "badge_friends_3")
            .frame(width: 80, height: 80)
    }
}
#endif
