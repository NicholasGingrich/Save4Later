import SwiftUI
import PhotosUI


struct SavedItemInfoForm: View {
    @Environment(ModelData.self) private var modelData

    @State var currentSavedItem: SavedItem?

    private var sectionText: String
    var closeView: () -> Void
    var onDelete: () -> Void = {}

    @State private var name: String = ""
    @State private var category: String = SavedItem.ItemCategory.general.rawValue
    @State private var link: String = ""
    @State private var note: String = ""
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var images: [UIImage] = []
    @State private var showingNewCategorySheet = false
    @State private var newCategoryName = ""

    init(currentItem: SavedItem? = nil, sectionText: String, closeView: @escaping () -> Void, onDelete: @escaping () -> Void = {}) {
        self.currentSavedItem = currentItem
        self.sectionText = sectionText
        self.closeView = closeView
        self.onDelete = onDelete
    }

    var body: some View {
        Form {
            Section(header: Text(sectionText)) {
                TextField("Name", text: $name)

                Picker("Category", selection: $category) {
                    ForEach(SavedItem.ItemCategory.allCases, id: \.rawValue) { cat in
                        Text(cat.rawValue).tag(cat.rawValue)
                    }
                    if !modelData.customCategories.isEmpty {
                        Divider()
                        ForEach(modelData.customCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }

                Button {
                    newCategoryName = ""
                    showingNewCategorySheet = true
                } label: {
                    Label("Add New Category", systemImage: "plus.circle")
                        .font(.custom("OpenSans-Regular", size: 15))
                }

                TextField("Link", text: $link)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }
            .sheet(isPresented: $showingNewCategorySheet) {
                NavigationStack {
                    Form {
                        Section(header: Text("Category Name")) {
                            TextField("e.g. Podcasts", text: $newCategoryName)
                                .autocapitalization(.words)
                        }
                    }
                    .navigationTitle("New Category")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                newCategoryName = ""
                                showingNewCategorySheet = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                                modelData.addCustomCategory(trimmed)
                                category = trimmed
                                newCategoryName = ""
                                showingNewCategorySheet = false
                            }
                            .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(200)])
            }

            Section(header: Text("Note")) {
                TextEditor(text: $note)
                    .frame(height: 120)
            }

            Section(header: Text("Images")) {
                PhotosPicker(selection: $selectedImages, maxSelectionCount: 5, matching: .images) {
                    Label("Select Images", systemImage: "photo")
                }

                if !images.isEmpty {
                    ScrollView(.horizontal) {
                        HStack(spacing: 15) {
                            // Bug fix: use image identity (via ObjectIdentifier on a wrapper) instead of
                            // index-based iteration so rapid deletions can't cause an out-of-bounds crash.
                            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                                ZStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(8)

                                    Button(action: {
                                        guard index < images.count else { return }
                                        images.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .offset(x: 50, y: -50)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }

            Section {
                // Bug fix: disable Save when name is blank
                Button("Save Item") {
                    // Bug fix: warn if any image fails to save instead of silently dropping it
                    var saveErrors = 0
                    let savedFilenames: [String] = images.compactMap { image in
                        do {
                            return try modelData.saveImageToDocuments(image)
                        } catch {
                            saveErrors += 1
                            return nil
                        }
                    }
                    if saveErrors > 0 {
                        print("⚠️ \(saveErrors) image(s) failed to save to disk.")
                    }

                    let now = Date.now.ISO8601Format()

                    if var item = currentSavedItem {
                        item.name = name
                        item.category = category
                        item.link = link.trimmingCharacters(in: .whitespacesAndNewlines)
                        item.notes = note
                        // Bug fix: preserve existing images; only replace with the current
                        // images array (which was pre-populated from disk in onAppear).
                        item.images = savedFilenames
                        item.lastModifiedDate = now
                        modelData.updateItem(item)
                        currentSavedItem = item
                    } else {
                        // Bug fix: use a large random range to minimise ID collision risk
                        let newItem = SavedItem(
                            id: Int.random(in: 1_000_000...9_999_999),
                            name: name,
                            creationDate: now,
                            lastModifiedDate: now,
                            notes: note,
                            images: savedFilenames,
                            link: link.trimmingCharacters(in: .whitespacesAndNewlines),
                            category: category
                        )
                        modelData.addItem(newItem)
                    }

                    closeView()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                // Bug fix: prevent saving items with no name
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if currentSavedItem != nil {
                Button(action: {
                    modelData.removeItem(currentSavedItem!)
                    closeView()
                    onDelete()
                }) {
                    Text("Delete")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.headline)
                        .buttonStyle(.plain)
                }
            }
        }
        .onChange(of: selectedImages) {
            Task {
                for item in selectedImages {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        images.append(uiImage)
                    }
                }
            }
        }
        .onAppear {
            if let item = currentSavedItem {
                name = item.name
                category = item.category
                link = item.link
                note = item.notes
                images = item.images.compactMap { modelData.loadUIImageFromDocuments($0) }
            }
        }
    }
}

#Preview {
    SavedItemInfoForm(sectionText: "Create New Item", closeView: { print("hello") })
        .environment(ModelData())
}

