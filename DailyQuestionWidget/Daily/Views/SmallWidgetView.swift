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
                        .frame(width: 20, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    
                    Text("Talko")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                
                Text(text)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .lineLimit(7)
                    .minimumScaleFactor(0.75)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
