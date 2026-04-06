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
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: -10) {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 0) {
                            ForEach(savedItem.images, id: \.self) { name in
                                if let image = modelData.loadImageFromDocuments(name) {
                                    RoundedImage(image: image)
                                        .frame(width: geometry.size.width * 0.92, height: geometry.size.height * 0.7)
                                        .clipped()
                                        .padding(.horizontal)
                                } else {
                                    RoundedImage(image: Image(name))
                                        .frame(width: geometry.size.width * 0.92, height: geometry.size.height * 0.7)
                                        .clipped()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Text(savedItem.name)                .font(.custom("OpenSans-Regular", size: 19)).fontWeight(.semibold)
                            Spacer()
                            Button {
                                showEditScreen.toggle()
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                            }
                        }
                        Text("Created on \(savedItem.creationDate)")
                            .font(.custom("OpenSans-Regular", size: 13))
                            .fontWeight(.medium)
                            .foregroundColor(Color.gray)
                        Text("\(savedItem.category)".titleCased)
                            .font(.custom("OpenSans-Regular", size: 15))
                            .fontWeight(.medium)
                            .foregroundColor(Color.gray)
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes")
                            .font(.custom("OpenSans-Regular", size: 16))
                            .fontWeight(.bold)
                        ExpandableText(text: savedItem.notes)

                        // Conditionally show the Visit button
                        if !savedItem.link.isEmpty {
                            Button(action: {
                                // Bug fix: validate URL and give user feedback if it's malformed
                                if let url = URL(string: savedItem.link),
                                   UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                } else {
                                    showInvalidURLAlert = true
                                }
                            }) {
                                Text("Visit")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .font(.custom("OpenSans-Regular", size: 16))
                            }
                        }
                    }
                    .padding()

                }
            }
        }
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
            if wasDeleted {
                dismiss()
            }
        }
        // Bug fix: alert user when the stored link can't be opened
        .alert("Invalid Link", isPresented: $showInvalidURLAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The link saved for this item doesn't appear to be a valid URL.")
        }
    }
}

#Preview {
    let modelData = ModelData()
    // Bug fix: guard against empty sample data in preview
    let item = modelData.savedItems.first ?? SavedItem(
        id: 0, name: "Preview", creationDate: "", lastModifiedDate: "",
        notes: "", images: [], link: "", category: .general
    )
    return SavedItemDetail(initialItem: item).environment(modelData)
}
