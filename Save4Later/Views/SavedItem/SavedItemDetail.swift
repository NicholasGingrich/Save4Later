import SwiftUI

struct SavedItemDetail: View {
    @State private var editableItem: SavedItem? = nil
    @State private var showEditScreen: Bool = false
    @State private var wasDeleted = false
    
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
                            Text(savedItem.name).font(.title2)
                            Spacer()
                            Button {
                                editableItem = savedItem
                                showEditScreen.toggle()
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                            }
                        }
                        Text("Created on \(savedItem.creationDate)")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                        Text("\(savedItem.category)".titleCased)
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                        ExpandableText(text: savedItem.notes)
                        Button(action: {
                            if let url = URL(string: savedItem.link) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Visit")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showEditScreen) {
            SavedItemInfoForm(
                currentItem: $editableItem,
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
    }
}

#Preview {
    let modelData = ModelData()
    return SavedItemDetail(initialItem: modelData.savedItems[0]).environment(modelData)
}
