import SwiftUI
 
struct CardProgressView: View {
    let value: Double
    let label: String
 
    var body: some View {
        HStack(spacing: 12) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 4)
 
                    Capsule()
                        .fill(Color.primary)
                        .frame(width: geo.size.width * value, height: 4)
                }
            }
            .frame(height: 4)
 
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize()
        }
        .padding(.horizontal, 20)
    }
}
