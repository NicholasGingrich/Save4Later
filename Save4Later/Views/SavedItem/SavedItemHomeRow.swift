import SwiftUI

struct SavedItemHomeRow: View {
    var categoryName: String
    var rowItems: [SavedItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(categoryName.pluralize.capitalized)
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(rowItems, id: \.self) { savedItem in
                        NavigationLink {
                            SavedItemDetail(initialItem: savedItem)
                        } label: {
                            SavedItemPreview(savedItem: savedItem)
                        }
                    }
                }
            }
        }.padding()
    }
}

#Preview {
    let savedItems = ModelData().savedItems
    return SavedItemHomeRow(categoryName: "Test Category Name" ,rowItems: Array(savedItems.prefix(4)))
}
