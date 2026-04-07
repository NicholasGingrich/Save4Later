import SwiftUI

struct SavedItemPreview: View {
    var savedItem: SavedItem

    private let cardWidth: CGFloat = 160
    private let cardHeight: CGFloat = 210

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Explicit frame on image so scaledToFill knows both dimensions
            savedItem.previewImage
                .renderingMode(.original)
                .resizable()
                .scaledToFill()
                .frame(width: cardWidth, height: cardHeight)
                .clipped()

            // Gradient scrim
            LinearGradient(
                colors: [.clear, .black.opacity(0.72)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(width: cardWidth, height: cardHeight)

            // Name + category overlay
            VStack(alignment: .leading, spacing: 3) {
                Text(savedItem.category.uppercased())
                    .font(.custom("OpenSans-Regular", size: 9))
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.75))
                    .tracking(0.8)

                Text(savedItem.name)
                    .font(.custom("OpenSans-Regular", size: 12))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    let modelData = ModelData()
    let item = modelData.savedItems.indices.contains(3)
        ? modelData.savedItems[3]
        : modelData.savedItems.first ?? SavedItem(
            id: 0, name: "Preview", creationDate: "", lastModifiedDate: "",
            notes: "", images: [], link: "", category: "General"
        )
    return SavedItemPreview(savedItem: item)
        .environment(modelData)
        .padding()
}
