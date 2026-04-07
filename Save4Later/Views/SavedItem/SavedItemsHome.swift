import SwiftUI

struct SavedItemsHome: View {
    @Environment(ModelData.self) private var modelData
    @State private var showingCreateScreen = false

    var body: some View {
        NavigationSplitView {
            List {
                if modelData.savedItems.isEmpty {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.s4lAccentLight)
                                .frame(width: 90, height: 90)
                            Image(systemName: "bookmark.slash")
                                .font(.system(size: 36))
                                .foregroundColor(Color.s4lAccent)
                        }
                        Text("Nothing saved yet")
                            .font(.custom("OpenSans-Regular", size: 20))
                            .fontWeight(.bold)
                        Text("Tap + to save your first item, or share a link from any app.")
                            .font(.custom("OpenSans-Regular", size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                } else {
                    SlideshowView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())

                    ForEach(modelData.categories.keys.sorted(), id: \.self) { category in
                        if let rowItems = modelData.categories[category] {
                            SavedItemHomeRow(categoryName: category, rowItems: rowItems)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets())
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateScreen.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color.s4lAccent)
                    }
                }
            }
            .sheet(isPresented: $showingCreateScreen) {
                SavedItemInfoForm(
                    sectionText: "Create New Item",
                    closeView: { showingCreateScreen.toggle() }
                )
            }
        } detail: {
            VStack(spacing: 12) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 32))
                    .foregroundColor(Color.s4lAccent.opacity(0.4))
                Text("Select an item to view")
                    .font(.custom("OpenSans-Regular", size: 16))
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    SavedItemsHome()
        .environment(ModelData())
}
