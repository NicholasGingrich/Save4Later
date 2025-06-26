import SwiftUI
import PhotosUI

struct CreateSavedItem: View {
    @State private var name: String = ""
    @State private var category: String = "General"
    @State private var link: String = ""
    @State private var note: String = ""
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var images: [Image] = []
    
    let categories = ["Movie", "TV Show", "Song", "Restaurant", "Activity", "Place", "Book", "Recipe", "General"]
    
    var body: some View {
        Form {
            Section(header: Text("Create New Item")) {
                TextField("Name", text: $name)

                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) {
                        Text($0)
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
                                images[index]
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
                    print("Saved item: \(name), \(category), \(link), \(note), \(images.count) images")
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
                        images.append(Image(uiImage: uiImage))
                    }
                }
            }
        }

    }
}

#Preview {
    CreateSavedItem()
}

