import SwiftUI

struct SavedItemHomeRow: View {
    var categoryName: String
    var rowItems: [SavedItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header
            HStack(alignment: .center, spacing: 8) {
                Circle()
                    .fill(Color.s4lAccent)
                    .frame(width: 7, height: 7)

                Text(categoryName.titleCased)
                    .font(.custom("OpenSans-Regular", size: 15))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(rowItems.count)")
                    .font(.custom("OpenSans-Regular", size: 12))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(minWidth: 22, minHeight: 22)
                    .background(Color.s4lAccentLight)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.s4lAccent.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal)

            // Horizontal scroll of cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(rowItems, id: \.self) { savedItem in
                        NavigationLink {
                            SavedItemDetail(initialItem: savedItem)
                        } label: {
                            SavedItemPreview(savedItem: savedItem)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 6)
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    let savedItems = ModelData().savedItems
    return SavedItemHomeRow(categoryName: "Recipes", rowItems: Array(savedItems.prefix(4)))
        .environment(ModelData())
}
