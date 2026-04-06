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
    
    
    func postDataUpdatedNotification() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.save4later.dataUpdated" as CFString),
            nil, nil,
            true
        )
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
                            // Bug fix: use enumerated() so index stays valid during rapid deletions
                            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
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
                                    .offset(x: -5, y: 5)
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
                    let now = Date().ISO8601Format()
                    let item = SharedSavedItem(
                        // Bug fix: larger ID space to minimise collision risk
                        id: Int.random(in: 1_000_000...9_999_999),
                        name: name,
                        creationDate: now,
                        lastModifiedDate: now,
                        notes: note,
                        images: images.compactMap { $0.jpegData(compressionQuality: 0.8) },
                        link: link.trimmingCharacters(in: .whitespacesAndNewlines),
                        category: category
                    )

                    do {
                        let data = try JSONEncoder().encode(item)
                        // Bug fix: guard against misconfigured app group instead of force-unwrapping
                        guard let groupURL = FileManager.default
                            .containerURL(forSecurityApplicationGroupIdentifier: "group.save4later") else {
                            print("[Extension] ❌ Could not access app group container 'group.save4later'")
                            return
                        }
                        print("[Extension] Group container URL: \(groupURL.path)")

                        let fileURL = groupURL.appendingPathComponent("savedItemToImport.json")
                        print("[Extension] About to write shared item JSON to: \(fileURL.path)")

                        try data.write(to: fileURL, options: .atomic)
                        print("[Extension] ✅ Successfully wrote shared item at \(Date())")

                        postDataUpdatedNotification()
                        print("[Extension] 📢 Posted Darwin notification: com.save4later.dataUpdated")

                    } catch {
                        print("[Extension] ❌ Error encoding or writing shared item: \(error)")
                    }

                    onSave?()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                // Bug fix: prevent saving items with no name
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
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
