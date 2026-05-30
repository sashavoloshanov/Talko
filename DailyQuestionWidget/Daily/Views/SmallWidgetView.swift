import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Image("applicationIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    
                    Text("Talk")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                
                Text(text)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(6)
                    .minimumScaleFactor(0.85)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
