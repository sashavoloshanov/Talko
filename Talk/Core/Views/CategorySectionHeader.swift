import SwiftUI

struct CategorySectionHeader: View {
    let emoji: String
    let name: String

    var body: some View {
        HStack(spacing: 8) {
            Text(emoji)
                .font(.title2)
            Text(name)
                .font(.title2.bold())
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
#Preview("Dark") {
    PreviewContainer(scheme: .dark) {
        CategorySectionHeader(emoji: "🧠", name: "Psychology")
    }
}

#Preview("Light") {
    PreviewContainer(scheme: .light) {
        CategorySectionHeader(emoji: "🧠", name: "Psychology")
    }
}
#endif
