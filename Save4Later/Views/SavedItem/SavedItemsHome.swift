import SwiftUI

struct SavedItemsHome: View {
    @Environment(ModelData.self) private var modelData
    @State private var showingCreateScreen = false

    var body: some View {
        NavigationSplitView {
            List {
                if modelData.savedItems.isEmpty {
                    // Bug fix: show helpful empty state instead of a blank list
                    VStack(spacing: 12) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Nothing saved yet")
                            .font(.custom("OpenSans-Regular", size: 18))
                            .fontWeight(.semibold)
                        Text("Tap + to save your first item, or share a link from any app.")
                            .font(.custom("OpenSans-Regular", size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    SlideshowView()

                    ForEach(modelData.categories.keys.sorted(), id: \.self) { category in
                        // Fix: safe subscript so a final render pass after deletion can't crash
                        if let rowItems = modelData.categories[category] {
                            SavedItemHomeRow(categoryName: category, rowItems: rowItems)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }
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
