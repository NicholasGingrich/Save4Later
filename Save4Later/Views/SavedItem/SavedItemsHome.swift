import SwiftUI

struct SavedItemsHome: View {
    @Environment(ModelData.self) private var modelData
    @State private var showingCreateScreen = false
    @State private var searchText = ""

    var searchResults: [SavedItem] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let query = searchText.lowercased()
        return modelData.savedItems.filter {
            $0.name.lowercased().contains(query) ||
            $0.notes.lowercased().contains(query) ||
            $0.link.lowercased().contains(query) ||
            $0.category.lowercased().contains(query)
        }
    }

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            Color.s4lBackground.ignoresSafeArea()
            NavigationSplitView {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if isSearching {
                            // ── Search results ──────────────────────────────────
                            if searchResults.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 36))
                                        .foregroundColor(Color.s4lAccent.opacity(0.4))
                                    Text("No results for \"\(searchText)\"")
                                        .font(.custom("OpenSans-Regular", size: 16))
                                        .fontWeight(.semibold)
                                    Text("Try searching by title, category, notes, or link.")
                                        .font(.custom("OpenSans-Regular", size: 13))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                                .padding(.horizontal, 16)
                            } else {
                                ForEach(searchResults) { item in
                                    SearchResultCard(item: item, query: searchText)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 4)
                                }
                            }
                        } else if modelData.savedItems.isEmpty {
                            // ── Empty state ─────────────────────────────────────
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
                        } else {
                            // ── Normal home view ────────────────────────────────
                            SlideshowView()

                            ForEach(modelData.categories.keys.sorted(), id: \.self) { category in
                                if let rowItems = modelData.categories[category] {
                                    SavedItemHomeRow(categoryName: category, rowItems: rowItems)
                                }
                            }
                        }
                    }
                }
                .background(Color.s4lBackground)
                .toolbarBackground(Color.s4lBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationTitle("Saved")
                .navigationBarTitleDisplayMode(.large)
                .searchable(text: $searchText, prompt: "Search items, categories, notes…")
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.s4lBackground)
            }
        } // ZStack
    }
}

// MARK: - Search result card (owns its own context menu state)

struct SearchResultCard: View {
    @Environment(ModelData.self) private var modelData
    let item: SavedItem
    let query: String

    @State private var isEditing = false
    @State private var isConfirmingDelete = false

    var body: some View {
        NavigationLink {
            SavedItemDetail(initialItem: item)
        } label: {
            SearchResultRow(item: item, query: query)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                isEditing = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                isConfirmingDelete = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } preview: {
            SearchResultRow(item: item, query: query)
                .frame(width: 300)
                .padding(4)
        }
        .sheet(isPresented: $isEditing) {
            SavedItemInfoForm(
                currentItem: item,
                sectionText: "Edit Item",
                closeView: { isEditing = false }
            )
        }
        .alert("Delete \"\(item.name)\"?", isPresented: $isConfirmingDelete) {
            Button("Delete", role: .destructive) {
                modelData.removeItem(item)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
    }
}

// MARK: - Search result row (visual only)

struct SearchResultRow: View {
    let item: SavedItem
    let query: String

    var body: some View {
        HStack(spacing: 14) {
            item.previewImage
                .renderingMode(.original)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.custom("OpenSans-Regular", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(item.category)
                    .font(.custom("OpenSans-Regular", size: 11))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.s4lAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.s4lAccentLight)
                    .clipShape(Capsule())

                if !item.notes.isEmpty && item.notes.lowercased().contains(query.lowercased()) {
                    Text(item.notes)
                        .font(.custom("OpenSans-Regular", size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(Color.s4lSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    SavedItemsHome()
        .environment(ModelData())
}
