import SwiftUI
import UIKit

import Foundation

// Weak wrapper so the Darwin C callback (which can't capture Swift closures with
// weak refs directly) has a safe way to reach the current ModelData instance.
private class WeakModelDataBox {
    weak var value: ModelData?
    init(_ value: ModelData) { self.value = value }
}
private var sharedModelBox: WeakModelDataBox?

@Observable
class ModelData {
    var savedItems: [SavedItem] = []
    /// User-created category names, persisted alongside saved items.
    var customCategories: [String] = []

    init() {
        sharedModelBox = WeakModelDataBox(self)
        loadSavedItems()
        loadCustomCategories()
        startObservingSharedData()
    }

    deinit {
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passRetained(self).toOpaque(),
            CFNotificationName("com.save4later.dataUpdated" as CFString),
            nil
        )
    }

    private func startObservingSharedData() {
        let notificationName = "com.save4later.dataUpdated" as CFString

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            nil,
            { _, _, _, _, _ in
                DispatchQueue.main.async {
                    sharedModelBox?.value?.importSharedItemIfAvailable()
                }
            },
            notificationName,
            nil,
            .deliverImmediately
        )
    }
    
    var categories: [String: [SavedItem]] {
        Dictionary(grouping: savedItems, by: { $0.category })
    }


    private func getDocumentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func savedItemsURL() -> URL {
        getDocumentsURL().appendingPathComponent("savedItems.json")
    }

    // Custom categories are stored in the shared app group container so the
    // share extension can also read and write them.
    private func appGroupURL() -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.save4later")
    }

    private func customCategoriesURL() -> URL? {
        appGroupURL()?.appendingPathComponent("customCategories.json")
    }

    func loadCustomCategories() {
        guard let url = customCategoriesURL(),
              FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String].self, from: data) else { return }
        customCategories = decoded
    }

    private func saveCustomCategoriesToDisk() {
        guard let url = customCategoriesURL(),
              let data = try? JSONEncoder().encode(customCategories) else { return }
        try? data.write(to: url, options: .atomic)
    }

    /// Adds a new custom category if it isn't blank and doesn't already exist.
    func addCustomCategory(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let builtIns = SavedItem.ItemCategory.allCases.map(\.rawValue)
        guard !trimmed.isEmpty,
              !customCategories.contains(trimmed),
              !builtIns.contains(trimmed) else { return }
        customCategories.append(trimmed)
        saveCustomCategoriesToDisk()
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

    @discardableResult
    func saveToDisk() -> Bool {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(savedItems)
            try data.write(to: savedItemsURL())
            return true
        } catch {
            print("❌ Failed to save savedItems.json to disk: \(error)")
            return false
        }
    }

    func addItem(_ item: SavedItem) {
        savedItems.append(item)
        if !saveToDisk() {
            savedItems.removeLast()
        }
    }

    func removeItem(_ item: SavedItem) {
        guard let index = savedItems.firstIndex(where: { $0.id == item.id }) else { return }
        let removed = savedItems[index]
        savedItems.remove(at: index)
        if !saveToDisk() {
            savedItems.insert(removed, at: index)
        }
    }

    func updateItem(_ updatedItem: SavedItem) {
        guard let index = savedItems.firstIndex(where: { $0.id == updatedItem.id }) else { return }
        let previous = savedItems[index]
        savedItems[index] = updatedItem
        if !saveToDisk() {
            savedItems[index] = previous
        }
    }
    
    func importSharedItemIfAvailable() {
        guard let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.save4later") else {
            print("❌ Could not access app group container 'group.save4later'")
            return
        }
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
                category: sharedItem.category
            )

            // Refresh custom categories since the extension may have created new ones
            loadCustomCategories()

            // Avoid duplicates when same item is shared twice
            if let existingIndex = savedItems.firstIndex(where: { $0.id == savedItem.id }) {
                savedItems[existingIndex] = savedItem
                saveToDisk()
            } else {
                addItem(savedItem)
            }

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



