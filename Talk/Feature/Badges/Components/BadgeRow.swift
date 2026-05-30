import SwiftUI

struct BadgeRow: View {
    let badge: Badge
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    if badge.isEarned {
                        Image(badge.imageName)
                            .resizable()
                            .scaledToFit()
                            .padding(8)
                    } else {
                        Image("lockedBadgeIcon")
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview("Locked") {
    BadgeRow(badge: Badge(
        id: "couple",
        subcategoryId: "know_me",
        subcategoryName: "Know Me",
        isEarned: false,
        imageName: "lockedBadgeIcon",
        name: "Know Me"
    ),
             onTap: {}
    )
}

#Preview("Earned") {
    BadgeRow(badge: Badge(
        id: "couple",
        subcategoryId: "know_me",
        subcategoryName: "Know Me",
        isEarned: true,
        imageName: "badge_know_me_10",
        name: "Know Me"
    ),
             onTap: {}
    )
}
#endif
