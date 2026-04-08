import SwiftUI

struct SavedItemDetail: View {
    @State private var showEditScreen: Bool = false
    @State private var wasDeleted = false
    @State private var showInvalidURLAlert = false

    @Environment(ModelData.self) private var modelData
    @Environment(\.dismiss) var dismiss

    let initialItem: SavedItem
    var savedItem: SavedItem {
        modelData.savedItems.first(where: { $0.id == initialItem.id }) ?? initialItem
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // ── Image carousel ──────────────────────────────────────
                if !savedItem.images.isEmpty {
                    TabView {
                        ForEach(savedItem.images, id: \.self) { name in
                            Group {
                                if let img = modelData.loadImageFromDocuments(name) {
                                    img.resizable().scaledToFill()
                                } else {
                                    Image(name).resizable().scaledToFill()
                                }
                            }
                            .clipped()
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .frame(height: 300)
                    .clipped()
                } else {
                    // Placeholder when no images
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

                // ── Info block ──────────────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        // Category pill
                        Text(savedItem.category.titleCased)
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
                            showEditScreen.toggle()
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color.s4lAccent)
                        }
                    }

                    Text(savedItem.name)
                        .font(.custom("OpenSans-Regular", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Saved \(savedItem.creationDate)")
                        .font(.custom("OpenSans-Regular", size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Divider().padding(.horizontal, 20)

                // ── Notes ───────────────────────────────────────────────
                if !savedItem.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("NOTES")
                            .font(.custom("OpenSans-Regular", size: 11))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(1)

                        ExpandableText(text: savedItem.notes)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    Divider().padding(.horizontal, 20)
                }

                // ── Visit button ─────────────────────────────────────────
                if !savedItem.link.isEmpty {
                    Button(action: {
                        if let url = URL(string: savedItem.link),
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
        }
        .background(Color.s4lBackground)
        .toolbarBackground(Color.s4lBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showEditScreen) {
            SavedItemInfoForm(
                currentItem: savedItem,
                sectionText: "Edit Item",
                closeView: { showEditScreen = false },
                onDelete: {
                    wasDeleted = true
                    showEditScreen = false
                }
            )
        }
        .onChange(of: wasDeleted) {
            if wasDeleted { dismiss() }
        }
        .alert("Invalid Link", isPresented: $showInvalidURLAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The link saved for this item doesn't appear to be a valid URL.")
        }
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
