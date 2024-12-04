//
//  StorageManager.swift
//  iTunesDiskStorage
//
//  Created by Ибрагим Габибли on 16.11.2024.
//

import Foundation

final class DiskStorageManager {
    static let shared = DiskStorageManager()

    private let historyKey = "searchHistory.json"
    private let fileManager = FileManager.default

    private init() {}

    private var documentsDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    func saveAlbum(_ album: Album, for searchTerm: String) {
        let directoryPath = documentsDirectory.appendingPathComponent(searchTerm)

        if !fileManager.fileExists(atPath: directoryPath.path) {
            do {
                try fileManager.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create directory: \(error.localizedDescription)")
                return
            }
        }

        let albumFileName = "\(album.artistId).json"
        let fileURL = directoryPath.appendingPathComponent(albumFileName)

        do {
            let data = try JSONEncoder().encode(album)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save album: \(error.localizedDescription)")
        }
    }

    func loadAlbums(for searchTerm: String) -> [Album] {
        let directoryPath = documentsDirectory.appendingPathComponent(searchTerm)

        guard fileManager.fileExists(atPath: directoryPath.path) else {
            return []
        }

        do {
            let albumFiles = try fileManager.contentsOfDirectory(atPath: directoryPath.path)
            var albums = [Album]()

            for fileName in albumFiles {
                let fileURL = directoryPath.appendingPathComponent(fileName)
                let data = try Data(contentsOf: fileURL)
                let album = try JSONDecoder().decode(Album.self, from: data)

                albums.append(album)
            }

            return albums
        } catch {
            print("Error loading albums: \(error.localizedDescription)")
            return []
        }
    }

    func saveImage(_ image: Data, key: String) {
        let fileURL = documentsDirectory.appendingPathComponent("\(key)")

        do {
            try image.write(to: fileURL)
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
        }
    }

    func loadImage(key: String) -> Data? {
        let fileURL = documentsDirectory.appendingPathComponent("\(key)")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            return try Data(contentsOf: fileURL)
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            return nil
        }
    }

    func saveSearchTerm(_ term: String) {
        var history = getSearchHistory()

        guard !history.contains(term) else {
            return
        }

        history.append(term)
        saveSearchHistory(history)
    }

    func getSearchHistory() -> [String] {
        let fileURL = documentsDirectory.appendingPathComponent(historyKey)

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([String].self, from: data)
        } catch {
            print("Error retrieving search history: \(error.localizedDescription)")
            return []
        }
    }

    private func saveSearchHistory(_ history: [String]) {
        let fileURL = documentsDirectory.appendingPathComponent(historyKey)

        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save search history: \(error.localizedDescription)")
        }
    }
}
