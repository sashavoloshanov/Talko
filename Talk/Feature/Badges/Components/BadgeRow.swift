import SwiftUI

struct BadgeRow: View {
    let badge: Badge
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if badge.isEarned {
                    RemoteBadgeImage(imageName: badge.imageName)
                } else {
                    Image("lockedBadgeIcon")
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview("Locked") {
    BadgeRow(badge: Badge(
        id: "couple_1",
        categoryId: "couple",
        categoryName: "Couple",
        tier: 1,
        threshold: 10,
        progress: 4,
        isEarned: false,
        imageName: "lockedBadgeIcon",
        name: "Couple"
    ),
             onTap: {}
    )
}

#Preview("Earned") {
    BadgeRow(badge: Badge(
        id: "couple_1",
        categoryId: "couple",
        categoryName: "Couple",
        tier: 1,
        threshold: 10,
        progress: 12,
        isEarned: true,
        imageName: "badge_couple_1",
        name: "Couple"
    ),
             onTap: {}
    )
}
#endif
