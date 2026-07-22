import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image("applicationIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("Talko")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                // Bounded flexible frame + a low scale factor so long questions
                // shrink to fit instead of collapsing to nothing.
                Text(text)
                    .font(.callout)
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
