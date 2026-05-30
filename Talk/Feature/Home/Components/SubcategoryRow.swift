import SwiftUI

struct SubcategoryRow: View {
    let subcategory: Subcategory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(subcategory.emoji)
                        .font(.system(size: 32))
                    
                    Spacer()
                    
                    if subcategory.isPremium {
                        HStack {
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Colors.premiumGold)
                        }
                    }
                }

                Text(subcategory.name)
                    .font(.subheadline.bold())
                    .foregroundColor(Colors.textPrimary)
                    .lineLimit(2)

                Text(subcategory.description)
                    .font(.caption)
                    .foregroundColor(Colors.textSecondary)
                    .lineLimit(2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Colors.backgroundSecondary)
            )
        }
        .buttonStyle(.plain)
    }
}
