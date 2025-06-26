import SwiftUI

struct SavedItem: Codable, Hashable, Identifiable {
    let id: Int
    var name: String
    var creationDate: String
    var lastModifiedDate: String
    var notes: String
    var images: [String] // Image file names stored to disk
    var links: [String]
    var category: ItemCategory

    // Use this in UI when showing image preview
    var previewImage: Image {
        if let first = images.first {
            if first.hasSuffix(".jpg") || first.hasSuffix(".png") {
                // Assume it's a saved image file
                if let uiImage = UIImage(contentsOfFile: FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent(first).path) {
                    return Image(uiImage: uiImage)
                }
            }
            return Image(first) // fallback to asset
        }
        return Image(systemName: "photo")
    }

    enum ItemCategory: String, CaseIterable, Codable {
        case recipe = "Recipe"
        case book = "Book"
        case article = "Article"
        case song = "Song"
        case TvShow = "Show"
        case movie = "Movie"
        case restruant = "Restaurant"
        case place = "Place"
        case activty = "Activity"
        case general = "General"
    }
}


