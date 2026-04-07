import SwiftUI

struct SavedItemPreview: View {
    var savedItem: SavedItem
    
    var body: some View {
        VStack(alignment: .leading) {
            savedItem.previewImage
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 155, height: 155)
                .cornerRadius(5)
            
            Text(savedItem.name)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .font(.custom("OpenSans-Regular", size: 11))
                .fontWeight(.semibold)
        }
        .frame(maxWidth: 155)
    }
}

#Preview {
    let modelData = ModelData()
    // Bug fix: guard against hardcoded index being out of bounds
    let item = modelData.savedItems.indices.contains(3)
        ? modelData.savedItems[3]
        : modelData.savedItems.first ?? SavedItem(
            id: 0, name: "Preview", creationDate: "", lastModifiedDate: "",
            notes: "", images: [], link: "", category: "General"
        )
    return SavedItemPreview(savedItem: item)
        .environment(modelData)
}
