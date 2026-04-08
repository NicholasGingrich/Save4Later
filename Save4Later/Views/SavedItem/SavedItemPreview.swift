import SwiftUI

struct SavedItemPreview: View {
    var savedItem: SavedItem

    private let cardWidth: CGFloat = 160
    private let cardHeight: CGFloat = 210
    private var hasPreviewImage: Bool { !savedItem.images.isEmpty }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if hasPreviewImage {
                savedItem.previewImage
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: cardHeight)
                    .clipped()
            } else {
                LinearGradient(
                    colors: [Color.s4lAccent.opacity(0.28), Color.s4lAccent.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: cardWidth, height: cardHeight)

                Image(systemName: "bookmark.square.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color.s4lAccent.opacity(0.82))
            }

            // Name + category overlay — frosted pill so text reads on any image
            VStack(alignment: .leading, spacing: 3) {
                Text(savedItem.category.uppercased())
                    .font(.custom("OpenSans-Regular", size: 9))
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(0.8)

                Text(savedItem.name)
                    .font(.custom("OpenSans-Regular", size: 12))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .opacity(0.55)
            )
            .padding(8)
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
