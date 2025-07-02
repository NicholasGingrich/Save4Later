import SwiftUI
import PhotosUI

struct ShareFormView: View {
    @State private var name: String = ""
    @State private var category: String = "General"
    @State private var link: String = ""
    @State private var note: String = ""
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var images: [UIImage] = []

    let sectionText: String
    var onSave: (() -> Void)? = nil
    var initialLink: String
    var initialImage: UIImage?

    private let categories = [
        "General", "Recipes", "Books", "Articles", "Songs",
        "Shows", "Movies", "Restaurants", "Places", "Activities"
    ]
    
    init(name: String = "", category: String = "General", link: String = "", note: String = "", selectedImages: [PhotosPickerItem] = [], images: [UIImage] = [], sectionText: String, onSave: (() -> Void)? = nil, initialLink: String = "", initialImage: UIImage? = nil) {
        self.name = name
        self.category = category
        self.link = initialLink
        self.note = note
        self.selectedImages = selectedImages
        self.images = initialImage.map { [$0] } ?? []
        self.sectionText = sectionText
        self.onSave = onSave
        self.initialImage = initialImage
        self.initialLink = initialLink
    }

    var body: some View {
        Form {
            Section(header: Text(sectionText)) {
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
                        HStack(spacing: 15) {
                            ForEach(images.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
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
                                    .offset(x: -5, y: 5)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }

            Section {
                Button("Save Item") {
                    let now = Date().ISO8601Format()
                    let item = SharedSavedItem(
                        id: Int.random(in: 1000...9999),
                        name: name,
                        creationDate: now,
                        lastModifiedDate: now,
                        notes: note,
                        images: images.compactMap { $0.jpegData(compressionQuality: 0.8) },
                        link: link,
                        category: category
                    )

                    if let data = try? JSONEncoder().encode(item) {
                        let groupURL = FileManager.default
                            .containerURL(forSecurityApplicationGroupIdentifier: "group.save4later")!
                        let fileURL = groupURL.appendingPathComponent("savedItemToImport.json")
                        try? data.write(to: fileURL)
                    }

                    onSave?()
                }
                .frame(maxWidth: .infinity, alignment: .center)
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
    }
}
