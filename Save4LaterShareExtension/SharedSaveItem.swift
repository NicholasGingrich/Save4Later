import Foundation

struct SharedSavedItem: Codable {
    let id: Int
    let name: String
    let creationDate: String
    let lastModifiedDate: String
    let notes: String
    let images: [Data] // raw image data
    let link: String
    let category: String
}
