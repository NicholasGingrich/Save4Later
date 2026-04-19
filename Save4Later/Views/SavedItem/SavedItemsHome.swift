import SwiftUI

struct SavedItemsHome: View {
    enum SortOption: String, CaseIterable, Identifiable {
        case alphabetical = "Alphabetical"
        case newestFirst = "Newest to Oldest"
        case oldestFirst = "Oldest to Newest"

        var id: Self { self }
    }

    @Environment(ModelData.self) private var modelData
    @State private var searchText = ""
    @State private var selectedSort: SortOption = .newestFirst

    private let isoFormatter = ISO8601DateFormatter()

    var sortedSavedItems: [SavedItem] {
        sortItems(modelData.savedItems)
    }

    var groupedSortedItems: [String: [SavedItem]] {
        Dictionary(grouping: sortedSavedItems, by: { $0.category })
    }

    var searchResults: [SavedItem] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let query = searchText.lowercased()
        let filtered = modelData.savedItems.filter {
            $0.name.lowercased().contains(query) ||
            $0.notes.lowercased().contains(query) ||
            $0.link.lowercased().contains(query) ||
            $0.category.lowercased().contains(query)
        }
        return sortItems(filtered)
    }

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            Color.s4lBackground.ignoresSafeArea()
            NavigationSplitView {  // ← form covers are on the ZStack below, not here
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
                            sortHeader
                            SlideshowView()

                            ForEach(groupedSortedItems.keys.sorted(), id: \.self) { category in
                                if let rowItems = groupedSortedItems[category] {
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
                            presentItemForm()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color.s4lAccent)
                        }
                    }
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
        // Expose the edit action to all descendants (SearchResultCard, SavedItemDetail).
        .environment(\.requestEditItem, { [self] item in presentItemForm(item: item) })
    }

    // MARK: - UIKit full-screen form presentation
    //
    // SwiftUI's .sheet / .fullScreenCover are intercepted by
    // UISplitViewController on iPad and downgraded to a page-sheet card.
    // Presenting directly from the root UIWindow bypasses that entirely.

    private func presentItemForm(item: SavedItem? = nil) {
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let window = windowScene.windows.first(where: { $0.isKeyWindow })
                ?? windowScene.windows.first,
            let rootVC = window.rootViewController
        else { return }

        // Walk to the topmost already-presented view controller.
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        // A thin SwiftUI wrapper that reads @Environment(\.dismiss) so the
        // form's close button correctly dismisses the UIHostingController.
        struct FormWrapper: View {
            let item: SavedItem?
            @Environment(\.dismiss) private var dismiss
            var body: some View {
                SavedItemInfoForm(
                    currentItem: item,
                    sectionText: item == nil ? "Create New Item" : "Edit Item",
                    closeView: { dismiss() }
                )
                .font(.custom("OpenSans-Regular", size: 16))
            }
        }

        let hostingVC = UIHostingController(
            rootView: FormWrapper(item: item).environment(modelData)
        )
        hostingVC.modalPresentationStyle = .formSheet
        // 85 % of the screen width, 90 % of the height — large modal card on iPad,
        // ignored on iPhone (which uses its own sheet behaviour).
        hostingVC.preferredContentSize = CGSize(
            width:  window.bounds.width  * 0.85,
            height: window.bounds.height * 0.90
        )
        topVC.present(hostingVC, animated: true)
    }

    private func sortItems(_ items: [SavedItem]) -> [SavedItem] {
        switch selectedSort {
        case .alphabetical:
            return items.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .newestFirst:
            return items.sorted {
                parsedDate(from: $0.creationDate) > parsedDate(from: $1.creationDate)
            }
        case .oldestFirst:
            return items.sorted {
                parsedDate(from: $0.creationDate) < parsedDate(from: $1.creationDate)
            }
        }
    }

    private func parsedDate(from value: String) -> Date {
        isoFormatter.date(from: value) ?? .distantPast
    }

    private var sortHeader: some View {
        HStack {
            Text("Sort")
                .font(.custom("OpenSans-Regular", size: 13))
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Spacer()

            Menu {
                Picker("Sort", selection: $selectedSort) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selectedSort.rawValue)
                        .font(.custom("OpenSans-Regular", size: 13))
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Color.s4lAccent)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.s4lAccent.opacity(0.12))
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }
}

struct SearchResultCard: View {
    @Environment(ModelData.self) private var modelData
    @Environment(\.requestEditItem) private var requestEditItem
    let item: SavedItem
    let query: String

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
                requestEditItem(item)
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

struct SearchResultRow: View {
    let item: SavedItem
    let query: String
    private var hasPreviewImage: Bool { !item.images.isEmpty }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                if hasPreviewImage {
                    item.previewImage
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: [Color.s4lAccent.opacity(0.28), Color.s4lAccent.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "bookmark.square.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.s4lAccent.opacity(0.82))
                }
            }
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
