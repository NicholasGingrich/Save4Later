import SwiftUI
import PhotosUI

struct SavedItemInfoForm: View {
    @Environment(ModelData.self) private var modelData
    
    var sectionText: String

    @State private var name: String = ""
    @State private var category: SavedItem.ItemCategory = .general
    @State private var link: String = ""
    @State private var note: String = ""
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var images: [UIImage] = [] // hold raw UIImages

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
                PhotosPicker(
                    selection: $selectedImages,
                    maxSelectionCount: 5,
                    matching: .images,
                    label: {
                        Label("Select Images", systemImage: "photo")
                    }
                )

                if !images.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(images.indices, id: \.self) { index in
                                Image(uiImage: images[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }

            Section {
                Button("Save Item") {
                    var savedFilenames: [String] = []

                    for uiImage in images {
                        if let filename = try? modelData.saveImageToDocuments(uiImage) {
                            savedFilenames.append(filename)
                        }
                    }

                    let newItem = SavedItem(
                        id: Int.random(in: 100...999),
                        name: name,
                        creationDate: Date.now.ISO8601Format(),
                        lastModifiedDate: Date.now.ISO8601Format(),
                        notes: note,
                        images: savedFilenames,
                        link: link,
                        category: category
                    )

                    modelData.addItem(newItem)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onChange(of: selectedImages) {
            Task {
                images.removeAll()
                for item in selectedImages {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        images.append(uiImage)
                    }
                }
            }
        }
    }
}

#Preview {
    SavedItemInfoForm(sectionText: "Create New Item")
        .environment(ModelData())
}


