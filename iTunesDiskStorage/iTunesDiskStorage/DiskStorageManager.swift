//
//  StorageManager.swift
//  iTunesDiskStorage
//
//  Created by Ибрагим Габибли on 16.11.2024.
//

import Foundation
import Disk

final class DiskStorageManager {
    static let shared = DiskStorageManager()
    private let historyKey = "searchHistory.json"

    private init() {}

    func saveAlbums(_ albums: [Album], for searchTerm: String) {
        do {
            try Disk.save(albums, to: .documents, as: "\(searchTerm).json")
        } catch {
            print("Failed to save albums: \(error.localizedDescription)")
        }
    }

    func saveImage(_ image: Data, key: String) {
        do {
            try Disk.save(image, to: .documents, as: "\(key).png")
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
        }
    }

    func saveSearchTerm(_ term: String) {
        var history = getSearchHistory()
        guard !history.contains(term)  else {
            return
        }
            history.append(term)

        do {
            try Disk.save(history, to: .documents, as: historyKey)
        } catch {
            print("Failed to save search history: \(error.localizedDescription)")
        }
    }

    func loadAlbums(for searchTerm: String) -> [Album]? {
        do {
            let albums = try Disk.retrieve("\(searchTerm).json", from: .documents, as: [Album].self)
            return albums
        } catch {
            print("Error loading albums: \(error.localizedDescription)")
            return nil
        }
    }

    func loadImage(key: String) -> Data? {
        do {
            let imageData = try Disk.retrieve("\(key).png", from: .documents, as: Data.self)
            return imageData
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            return nil
        }
    }

    func getSearchHistory() -> [String] {
        do {
            return try Disk.retrieve(historyKey, from: .documents, as: [String].self)
        } catch {
            print("Error retrieving search history: \(error.localizedDescription)")
            return []
        }
    }

    func clearAlbums() {
        let history = getSearchHistory()
        for term in history {
            do {
                try Disk.remove("\(term).json", from: .documents)
            } catch {
                print("Error deleting album for term \(term): \(error.localizedDescription)")
            }
        }
        clearHistory()
    }

    func clearImage(key: String) {
        do {
            try Disk.remove("\(key).png", from: .documents)
        } catch {
            print("Error deleting image: \(error.localizedDescription)")
        }
    }

    func clearHistory() {
        do {
            try Disk.remove(historyKey, from: .documents)
        } catch {
            print("Error deleting search history: \(error.localizedDescription)")
        }
    }
}
