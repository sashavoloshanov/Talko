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
                
                Text(text)
                    .font(.callout)
                    .fontWeight(.medium)
                    .lineLimit(6)
                    .minimumScaleFactor(0.85)
            }
            
            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
