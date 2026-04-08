import SwiftUI

// MARK: - Individual card with its own context menu state

struct SavedItemCard: View {
    @Environment(ModelData.self) private var modelData
    let savedItem: SavedItem

    @State private var isEditing = false
    @State private var isConfirmingDelete = false

    var body: some View {
        NavigationLink {
            SavedItemDetail(initialItem: savedItem)
        } label: {
            SavedItemPreview(savedItem: savedItem)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                isEditing = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                isConfirmingDelete = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } preview: {
            SavedItemPreview(savedItem: savedItem)
        }
        .sheet(isPresented: $isEditing) {
            SavedItemInfoForm(
                currentItem: savedItem,
                sectionText: "Edit Item",
                closeView: { isEditing = false }
            )
        }
        .alert("Delete \"\(savedItem.name)\"?", isPresented: $isConfirmingDelete) {
            Button("Delete", role: .destructive) {
                modelData.removeItem(savedItem)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
    }
}

// MARK: - Category row

struct SavedItemHomeRow: View {
    var categoryName: String
    var rowItems: [SavedItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header
            HStack(alignment: .center, spacing: 8) {
                Circle()
                    .fill(Color.s4lAccent)
                    .frame(width: 7, height: 7)

                Text(categoryName.titleCased)
                    .font(.custom("OpenSans-Regular", size: 15))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(rowItems.count)")
                    .font(.custom("OpenSans-Regular", size: 12))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.s4lAccent)
                    .frame(minWidth: 22, minHeight: 22)
                    .background(Color.s4lAccent.opacity(0.18))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.s4lAccent.opacity(0.45), lineWidth: 1))
            }
            .padding(.horizontal)

            // Horizontal scroll of cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(rowItems, id: \.self) { savedItem in
                        SavedItemCard(savedItem: savedItem)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 6)
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    let savedItems = ModelData().savedItems
    return SavedItemHomeRow(categoryName: "Recipes", rowItems: Array(savedItems.prefix(4)))
        .environment(ModelData())
}
