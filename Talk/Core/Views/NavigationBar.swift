import SwiftUI

struct NavigationBar: View {
    @Environment(ThemeClient.self) private var themeClient
    
    let leftButton: (() -> Void)?
    let centerContent: NavCenterContent
    let rightButton: NavRightButton?

    var body: some View {
        HStack(spacing: 0) {
            Group {
                if let leftAction = leftButton {
                    Button(action: leftAction) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Colors.textPrimary)
                    }
                    .frame(width: 44, height: 44)
                } else {
                    Spacer()
                        .frame(width: 44, height: 44)
                }
            }

            Spacer()

            Group {
                switch centerContent {
                case .text(let title):
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Colors.textPrimary)
                        .lineLimit(1)
                case .icon(let image):
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                }
            }

            Spacer()

            Group {
                if let right = rightButton {
                    Button(action: right.action) {
                        Image(uiImage: right.icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .tint(Colors.textPrimary)
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 44, height: 44)
                } else {
                    Spacer()
                        .frame(width: 44, height: 44)
                }
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
        .background(Colors.backgroundPrimary)
    }
}

enum NavCenterContent {
    case text(String)
    case icon(UIImage)
}

struct NavRightButton {
    let icon: UIImage
    let action: () -> Void
}
