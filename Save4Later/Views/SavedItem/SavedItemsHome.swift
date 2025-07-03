import SwiftUI

struct SavedItemsHome: View {
    @Environment(ModelData.self) private var modelData
    @State private var showingCreateScreen = false

    var body: some View {
        NavigationSplitView {
            List {
                SlideshowView()

                ForEach(modelData.categories.keys.sorted(), id: \.self) { category in
                    SavedItemHomeRow(categoryName: category, rowItems: modelData.categories[category]!)
                }
                .listRowInsets(EdgeInsets())
            }
            .padding(.top)
            .listStyle(.inset)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Saved")
                        .font(.custom("OpenSans-Bold", size: 29))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding()
                }
                ToolbarItem {
                    Button {
                        showingCreateScreen.toggle()
                    } label: {
                        Label("Add New Saved Item", systemImage: "plus")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCreateScreen) {
                SavedItemInfoForm(
                    sectionText: "Create New Item",
                    closeView: { showingCreateScreen.toggle() }
                )
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
