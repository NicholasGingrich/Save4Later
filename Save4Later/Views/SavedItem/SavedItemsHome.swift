import SwiftUI

struct SavedItemsHome: View {
    @Environment(ModelData.self) private var modelData
    @State private var showingCreateScreen = false
    
    var body: some View {
        NavigationSplitView {
            List {
                modelData.savedItems[0].previewImage
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .listRowInsets(EdgeInsets())
                
                ForEach(modelData.categories.keys.sorted(), id: \.self) { category in
                    SavedItemHomeRow(categoryName: category, rowItems: modelData.categories[category]!)
                }
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.inset)
            .navigationTitle("Saved")
            .toolbar {
                Button {
                    showingCreateScreen.toggle()
                } label: {
                    Label("Add New Saved Item", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingCreateScreen) {
                CreateSavedItem()
            }
        } detail: {
            Text("Select a saved item to view")
        }
    }
}

#Preview {
    SavedItemsHome()
        .environment(ModelData())
}
