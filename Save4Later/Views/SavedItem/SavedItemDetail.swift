import SwiftUI

struct SavedItemDetail: View {
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
                        Button(action: {
                            if let url = URL(string: savedItem.link) {
                                UIApplication.shared.open(url)
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
    }
}

#Preview {
    let modelData = ModelData()
    return SavedItemDetail(initialItem: modelData.savedItems[0]).environment(modelData)
}
