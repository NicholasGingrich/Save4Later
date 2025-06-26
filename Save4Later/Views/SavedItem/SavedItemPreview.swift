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
                .font(.caption)
                .lineLimit(1)
        }
        .frame(maxWidth: 155)
    }
}

#Preview {
    let modelData = ModelData()
    return SavedItemPreview(savedItem: modelData.savedItems[3])
        .environment(ModelData())
}
