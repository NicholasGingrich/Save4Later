import SwiftUI

struct SavedItemDetail: View {
    @Environment(ModelData.self) private var modelData
    var savedItem: SavedItem

    @State private var expanded = false

    var body: some View {
            GeometryReader { geometry in
                ScrollView {

                VStack(alignment: .leading, spacing: -10) {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 0) {
                            ForEach(savedItem.images, id: \.self) { name in
                                // Check if file exists in Documents folder (saved user images)
                                if let image = modelData.loadImageFromDocuments(name) {
                                    RoundedImage(image: image)
                                        .frame(width: geometry.size.width * 0.92, height: geometry.size.height * 0.7)
                                        .clipped()
                                        .padding(.horizontal)
                                } else {
                                    // Otherwise, try loading from assets (bundled images)
                                    RoundedImage(image: Image(name))
                                        .frame(width: geometry.size.width * 0.92, height: geometry.size.height * 0.7)
                                        .clipped()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }

                    
                    VStack(alignment: .leading) {
                        Text(savedItem.name).font(.title2)
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
                        
                        Text("\(savedItem.notes)")
                            .font(.subheadline)
                            .padding(.leading)
                            .padding(.top, 0.1)
                            .lineLimit(expanded ? nil : 2)
                            .animation(.easeInOut, value: expanded)
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    expanded.toggle()
                                }
                            }) {
                                Text(expanded ? "See Less" : "See More")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button(action: {
                            if let url = URL(string: "https://www.youtube.com/watch?v=V4gC2JDwQDE") {
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
    }
}

#Preview {
    let modelData = ModelData()
    return SavedItemDetail(savedItem: modelData.savedItems[0]).environment(modelData)
}
