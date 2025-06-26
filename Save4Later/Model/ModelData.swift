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

    // MARK: - Disk URLs

    private func getDocumentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func savedItemsURL() -> URL {
        getDocumentsURL().appendingPathComponent("savedItems.json")
    }

    // MARK: - Save image to disk, return filename

    func saveImageToDocuments(_ uiImage: UIImage) throws -> String {
        let filename = UUID().uuidString + ".jpg"
        let url = getDocumentsURL().appendingPathComponent(filename)
        guard let data = uiImage.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversionError", code: 0)
        }
        try data.write(to: url)
        return filename
    }

    // MARK: - Load image from filename

    func loadImageFromDocuments(_ filename: String) -> Image? {
        let url = getDocumentsURL().appendingPathComponent(filename)
        if let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
    }

    // MARK: - Load and save savedItems JSON

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

