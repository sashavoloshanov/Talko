import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image("applicationIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

                Text("Talko")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }

            // Bounded flexible frame + a low scale factor so long questions
            // always shrink to fit instead of collapsing to nothing in the
            // small widget's tight box.
            Text(text)
                .font(.footnote)
                .fontWeight(.medium)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        // Show the question text even in the placeholder/loading state instead
        // of the system's grey redaction bars.
        .unredacted()
    }
}
