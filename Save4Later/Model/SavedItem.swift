import SwiftUI

struct SavedItem: Codable, Hashable, Identifiable {
    let id: Int
    var name: String
    var creationDate: String
    var lastModifiedDate: String
    var notes: String
    var images: [String]
    var link: String
    var category: String

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
            return Image(first) 
        }
        return Image(systemName: "photo")
    }

    enum ItemCategory: String, CaseIterable, Codable {
        case recipes = "Recipes"
        case books = "Books"
        case articles = "Articles"
        case songs = "Songs"
        case TvShows = "Shows"
        case movies = "Movies"
        case restruants = "Restaurants"
        case places = "Places"
        case activties = "Activities"
        case general = "General"
    }
}
