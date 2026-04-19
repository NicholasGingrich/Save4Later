import SwiftUI

struct SavedItemDetail: View {
    @Environment(\.requestEditItem) private var requestEditItem
    @State private var showInvalidURLAlert = false
    @State private var selectedImageIndex = 0
    @State private var showFullScreenGallery = false
    @State private var selectedItemID: Int

    @Environment(ModelData.self) private var modelData
    @Environment(\.dismiss) var dismiss

    let initialItem: SavedItem
    var savedItems: [SavedItem] {
        modelData.savedItems
    }

    init(initialItem: SavedItem) {
        self.initialItem = initialItem
        _selectedItemID = State(initialValue: initialItem.id)
    }

    private var currentItem: SavedItem {
        savedItems.first(where: { $0.id == selectedItemID }) ?? initialItem
    }

    private var currentIndex: Int {
        savedItems.firstIndex(where: { $0.id == selectedItemID }) ?? 0
    }

    private func friendlyCreationDate(for item: SavedItem) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = iso.date(from: item.creationDate)
            ?? ISO8601DateFormatter().date(from: item.creationDate)

        guard let date else {
            return item.creationDate
        }

        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            if savedItems.isEmpty {
                Color.s4lBackground.ignoresSafeArea()
            } else {
                TabView(selection: $selectedItemID) {
                    ForEach(savedItems) { item in
                        ScrollView {
                            detailContent(for: item)
                        }
                        .tag(item.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                if savedItems.count > 1 {
                    HStack(spacing: 20) {
                        Button {
                            let previous = max(currentIndex - 1, 0)
                            withAnimation(.smooth()) {
                                selectedItemID = savedItems[previous].id
                            }
                        } label: {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 28))
                                .symbolRenderingMode(.hierarchical)
                        }
                        .disabled(currentIndex == 0)

                        Text("\(currentIndex + 1) of \(savedItems.count)")
                            .font(.custom("OpenSans-Regular", size: 13))
                            .foregroundColor(.secondary)

                        Button {
                            let next = min(currentIndex + 1, savedItems.count - 1)
                            withAnimation(.smooth()) {
                                selectedItemID = savedItems[next].id
                            }
                        } label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 28))
                                .symbolRenderingMode(.hierarchical)
                        }
                        .disabled(currentIndex == savedItems.count - 1)
                    }
                    .foregroundColor(Color.s4lAccent)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.s4lBackground)
                }
            }
        }
        .background(Color.s4lBackground)
        .toolbarBackground(Color.s4lBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onChange(of: savedItems) { _, newItems in
            // If the currently viewed item was deleted (e.g. from the edit form),
            // pop back on iPhone / clear detail on iPad.
            if !newItems.contains(where: { $0.id == selectedItemID }) {
                if let first = newItems.first {
                    selectedItemID = first.id
                }
                dismiss()
            }
        }
        .alert("Invalid Link", isPresented: $showInvalidURLAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The link saved for this item doesn't appear to be a valid URL.")
        }
        .fullScreenCover(isPresented: $showFullScreenGallery) {
            FullScreenImageGallery(
                imageNames: currentItem.images,
                startIndex: selectedImageIndex
            )
        }
    }

    @ViewBuilder
    private func detailContent(for item: SavedItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !item.images.isEmpty {
                TabView {
                    ForEach(Array(item.images.enumerated()), id: \.element) { index, name in
                        Button {
                            selectedImageIndex = index
                            showFullScreenGallery = true
                        } label: {
                            Group {
                                if let img = modelData.loadImageFromDocuments(name) {
                                    img.resizable().scaledToFill()
                                } else {
                                    Image(name).resizable().scaledToFill()
                                }
                            }
                            .clipped()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(height: 300)
                .clipped()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [Color.s4lAccent.opacity(0.35), Color.s4lAccent.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "photo")
                        .font(.system(size: 52))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(height: 200)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Text(item.category.titleCased)
                        .font(.custom("OpenSans-Regular", size: 11))
                        .fontWeight(.bold)
                        .foregroundColor(Color.s4lAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.s4lAccentLight)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.s4lAccent.opacity(0.25), lineWidth: 1))

                    Spacer()

                    Button {
                        requestEditItem(currentItem)
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color.s4lAccent)
                    }
                }

                Text(item.name)
                    .font(.custom("OpenSans-Regular", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Saved \(friendlyCreationDate(for: item))")
                    .font(.custom("OpenSans-Regular", size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider().padding(.horizontal, 20)

            if !item.notes.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("NOTES")
                        .font(.custom("OpenSans-Regular", size: 11))
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .tracking(1)

                    ExpandableText(text: item.notes)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                Divider().padding(.horizontal, 20)
            }

            if !item.link.isEmpty {
                Button(action: {
                    if let url = URL(string: item.link),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        showInvalidURLAlert = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.right.square.fill")
                        Text("Visit")
                            .fontWeight(.semibold)
                    }
                    .font(.custom("OpenSans-Regular", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(
                        LinearGradient(
                            colors: [Color.s4lAccent, Color.s4lAccent.opacity(0.78)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: Color.s4lAccent.opacity(0.35), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .background(Color.s4lBackground)
    }
}

struct FullScreenImageGallery: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ModelData.self) private var modelData

    let imageNames: [String]
    let startIndex: Int
    @State private var selectedIndex: Int

    init(imageNames: [String], startIndex: Int) {
        self.imageNames = imageNames
        self.startIndex = startIndex
        _selectedIndex = State(initialValue: startIndex)
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedIndex) {
                ForEach(Array(imageNames.enumerated()), id: \.offset) { index, name in
                    ZStack {
                        Color.black.ignoresSafeArea()
                        imageForName(name)
                            .resizable()
                            .scaledToFit()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                    .tint(.white)
                }
                ToolbarItem(placement: .principal) {
                    Text("\(selectedIndex + 1) / \(max(imageNames.count, 1))")
                        .font(.custom("OpenSans-Regular", size: 14))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.white)
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .background(Color.black)
        }
        .preferredColorScheme(.dark)
    }

    private func imageForName(_ name: String) -> Image {
        if let image = modelData.loadImageFromDocuments(name) {
            return image
        }
        return Image(name)
    }
}

#Preview {
    let modelData = ModelData()
    let item = modelData.savedItems.first ?? SavedItem(
        id: 0, name: "Preview", creationDate: "", lastModifiedDate: "",
        notes: "Some notes here.", images: [], link: "https://apple.com", category: "General"
    )
    return SavedItemDetail(initialItem: item).environment(modelData)
}
