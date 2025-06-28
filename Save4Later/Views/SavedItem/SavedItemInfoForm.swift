import SwiftUI
import PhotosUI

struct SavedItemInfoForm: View {
    @Environment(ModelData.self) private var modelData

    @State var currentSavedItem: SavedItem?

    private var sectionText: String
    var closeView: () -> Void
    var onDelete: () -> Void = {}

    @State private var name: String = ""
    @State private var category: SavedItem.ItemCategory = .general
    @State private var link: String = ""
    @State private var note: String = ""
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var images: [UIImage] = []

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
                    ForEach(SavedItem.ItemCategory.allCases, id: \.self) { category in
                        Text(category.rawValue)
                    }
                }
                TextField("Link", text: $link)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
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
                            ForEach(images.indices, id: \.self) { index in
                                ZStack {
                                    Image(uiImage: images[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(8)
                                    
                                    Button(action: {
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
                Button("Save Item") {
                    let savedFilenames = images.compactMap { try? modelData.saveImageToDocuments($0) }
                    let now = Date.now.ISO8601Format()

                    if var item = currentSavedItem {
                        item.name = name
                        item.category = category
                        item.link = link
                        item.notes = note
                        item.images = savedFilenames
                        item.lastModifiedDate = now
                        modelData.updateItem(item)
                        currentSavedItem = item
                    } else {
                        let newItem = SavedItem(
                            id: Int.random(in: 100...999),
                            name: name,
                            creationDate: now,
                            lastModifiedDate: now,
                            notes: note,
                            images: savedFilenames,
                            link: link,
                            category: category
                        )
                        modelData.addItem(newItem)
                    }

                    closeView()
                }
                .frame(maxWidth: .infinity, alignment: .center)
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

