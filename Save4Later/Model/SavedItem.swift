import SwiftUI

struct SavedItem: Codable, Hashable, Identifiable {
    let id: Int
    var name: String
    var creationDate: String
    var lastModifiedDate: String
    var notes: String
    var images: [String]
    var category: ItemCategory
    var links: [String]
    
    var previewImage: Image {
        Image(images[0])
    }

    enum ItemCategory: String, CaseIterable, Codable {
        case recipe = "recipe"
        case book = "book"
        case article = "article"
        case song = "song"
        case TvShow = "show"
        case movie = "movie"
        case restruant = "restaurant"
        case place = "place"
        case activty = "activity"
    }
}

