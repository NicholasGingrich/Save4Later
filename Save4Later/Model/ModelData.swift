import SwiftUI
import UIKit

import Foundation

@Observable
class ModelData {
    var savedItems: [SavedItem] = []

    init() {
        loadSavedItems()
    }
    
    var categories: [String: [SavedItem]] {
        Dictionary(
            grouping: savedItems,
            by: { $0.category.rawValue }
        )    }


    private func getDocumentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func savedItemsURL() -> URL {
        getDocumentsURL().appendingPathComponent("savedItems.json")
    }

    func saveImageToDocuments(_ uiImage: UIImage) throws -> String {
        let filename = UUID().uuidString + ".jpg"
        let url = getDocumentsURL().appendingPathComponent(filename)
        guard let data = uiImage.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversionError", code: 0)
        }
        try data.write(to: url)
        return filename
    }
    
    func loadImageFromDocuments(_ filename: String) -> Image? {
        let url = getDocumentsURL().appendingPathComponent(filename)
        if let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
    }

    func loadUIImageFromDocuments(_ filename: String) -> UIImage? {
        let url = getDocumentsURL().appendingPathComponent(filename)
        if let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return uiImage
        }
        return nil
    }

    func loadSavedItems() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let fileURL = savedItemsURL()
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                savedItems = try decoder.decode([SavedItem].self, from: data)
                print("Saved items have loaded successfully. Here are the saved items \(savedItems)")
            } catch {
                print("❌ Failed to load savedItems.json from disk: \(error). Falling back to bundled JSON.")
                savedItems = load("savedItemsData.json")
            }
        } else {
            print("File does not exist. Error loading disk data failed, falling back to bundled JSON")
            savedItems = load("savedItemsData.json")
        }
    }

    func saveToDisk() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(savedItems)
            try data.write(to: savedItemsURL())
            print("Here we are saving to disk. Here is the data we are saving: \(data)")
        } catch {
            print("❌ Failed to save savedItems.json to disk: \(error)")
        }
    }

    func addItem(_ item: SavedItem) {
        savedItems.append(item)
        saveToDisk()
    }
    
    func removeItem(_ item: SavedItem) {
        print("here we are removing the item \(item)")

        if let index = savedItems.firstIndex(where: { $0.id == item.id }) {
            print("In the let statement. here we are removing the item \(item)")
            savedItems.remove(at: index)
            saveToDisk()
        }
    }
    
    func updateItem(_ updatedItem: SavedItem) {
        if let index = savedItems.firstIndex(where: { $0.id == updatedItem.id }) {
            savedItems[index] = updatedItem
            saveToDisk()
        }
    }
    
    func importSharedItemIfAvailable() {
        let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.save4later")!
        let fileURL = groupURL.appendingPathComponent("savedItemToImport.json")

        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }

        do {
            let data = try Data(contentsOf: fileURL)
            let sharedItem = try JSONDecoder().decode(SharedSavedItem.self, from: data)

            let filenames = try sharedItem.images.map { imageData -> String in
                let filename = UUID().uuidString + ".jpg"
                let imageURL = getDocumentsURL().appendingPathComponent(filename)
                try imageData.write(to: imageURL)
                return filename
            }

            let savedItem = SavedItem(
                id: sharedItem.id,
                name: sharedItem.name,
                creationDate: sharedItem.creationDate,
                lastModifiedDate: sharedItem.lastModifiedDate,
                notes: sharedItem.notes,
                images: filenames,
                link: sharedItem.link,
                category: SavedItem.ItemCategory(rawValue: sharedItem.category) ?? .general
            )

            addItem(savedItem)

            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error importing shared item: \(error)")
        }
    }

}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}



