import CryptoKit
import Foundation

enum BoardStoreError: LocalizedError {
    case invalidBoardData

    var errorDescription: String? {
        switch self {
        case .invalidBoardData:
            return "The board data could not be saved because it is not valid Lori's Voice board data."
        }
    }
}

final class BoardStore {
    static let shared = BoardStore()

    private let fileManager = FileManager.default
    private let photoPrefix = "loris-photo:"

    private init() {}

    private var boardDirectoryURL: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("LorisVoice", isDirectory: true)
    }

    private var boardFileURL: URL {
        boardDirectoryURL.appendingPathComponent("board.json", isDirectory: false)
    }

    private var previousBoardFileURL: URL {
        boardDirectoryURL.appendingPathComponent("board.previous.json", isDirectory: false)
    }

    private var photoDirectoryURL: URL {
        boardDirectoryURL.appendingPathComponent("Photos", isDirectory: true)
    }

    func loadJSON() -> String? {
        if let json = readValidJSON(from: boardFileURL) {
            return json
        }

        // If the primary file was interrupted or corrupted, fall back to the last
        // known-good copy rather than dropping the user back to the starter board.
        return readValidJSON(from: previousBoardFileURL)
    }

    func save(json: String) throws {
        try fileManager.createDirectory(
            at: boardDirectoryURL,
            withIntermediateDirectories: true
        )
        try fileManager.createDirectory(
            at: photoDirectoryURL,
            withIntermediateDirectories: true
        )

        guard let inputData = json.data(using: .utf8),
              var root = try? JSONSerialization.jsonObject(with: inputData) as? [String: Any],
              let tiles = root["tiles"] as? [Any] else {
            throw BoardStoreError.invalidBoardData
        }

        // Photos arrive from the web UI as data URLs. Persist those JPEG/PNG bytes
        // as individual files and keep only a lightweight reference in board.json.
        // This keeps the board file small while backups remain self-contained because
        // the web UI receives hydrated data URLs again when the app is reopened.
        root["tiles"] = persistImages(in: tiles)

        guard JSONSerialization.isValidJSONObject(root),
              let data = try? JSONSerialization.data(withJSONObject: root),
              Self.looksLikeBoardData(data) else {
            throw BoardStoreError.invalidBoardData
        }

        // Preserve the last good board before replacing it. This is intentionally
        // local-only and does not require a user action or network connection.
        if fileManager.fileExists(atPath: boardFileURL.path) {
            try? fileManager.removeItem(at: previousBoardFileURL)
            try? fileManager.copyItem(at: boardFileURL, to: previousBoardFileURL)
        }

        try data.write(to: boardFileURL, options: .atomic)
        cleanupUnusedPhotoFiles(currentRoot: root)
    }

    var storageDescription: String {
        "On this device"
    }

    private func readValidJSON(from url: URL) -> String? {
        guard let data = try? Data(contentsOf: url),
              Self.looksLikeBoardData(data),
              var root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tiles = root["tiles"] as? [Any] else {
            return nil
        }

        // Convert lightweight on-disk photo references back to data URLs for the
        // bundled HTML UI. Missing photo files simply fall back to the tile emoji.
        root["tiles"] = hydrateImages(in: tiles)

        guard let hydratedData = try? JSONSerialization.data(withJSONObject: root),
              let json = String(data: hydratedData, encoding: .utf8) else {
            return nil
        }
        return json
    }

    private func persistImages(in tiles: [Any]) -> [Any] {
        tiles.map { item in
            guard var tile = item as? [String: Any] else { return item }

            if let image = tile["image"] as? String,
               image.hasPrefix("data:image/"),
               let reference = persistImageDataURL(image) {
                tile["image"] = reference
            }

            if let children = tile["children"] as? [Any] {
                tile["children"] = persistImages(in: children)
            }
            return tile
        }
    }

    private func hydrateImages(in tiles: [Any]) -> [Any] {
        tiles.map { item in
            guard var tile = item as? [String: Any] else { return item }

            if let image = tile["image"] as? String,
               image.hasPrefix(photoPrefix) {
                if let dataURL = dataURL(forReference: image) {
                    tile["image"] = dataURL
                } else {
                    tile.removeValue(forKey: "image")
                }
            }

            if let children = tile["children"] as? [Any] {
                tile["children"] = hydrateImages(in: children)
            }
            return tile
        }
    }

    private func persistImageDataURL(_ dataURL: String) -> String? {
        guard let comma = dataURL.firstIndex(of: ",") else { return nil }
        let header = String(dataURL[..<comma]).lowercased()
        let encoded = String(dataURL[dataURL.index(after: comma)...])
        guard header.contains(";base64"),
              let data = Data(base64Encoded: encoded),
              !data.isEmpty else { return nil }

        let ext: String
        let mime: String
        if header.contains("image/png") {
            ext = "png"
            mime = "image/png"
        } else {
            ext = "jpg"
            mime = "image/jpeg"
        }

        let digest = SHA256.hash(data: data)
        let hash = digest.map { String(format: "%02x", $0) }.joined()
        let filename = "photo-\(hash).\(ext)"
        let url = photoDirectoryURL.appendingPathComponent(filename)

        if !fileManager.fileExists(atPath: url.path) {
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                return nil
            }
        }

        // The MIME value is intentionally encoded in the filename extension so the
        // reference itself can stay short and human-readable.
        _ = mime
        return photoPrefix + filename
    }

    private func dataURL(forReference reference: String) -> String? {
        let filename = String(reference.dropFirst(photoPrefix.count))
        guard !filename.isEmpty else { return nil }
        let url = photoDirectoryURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }

        let mime = filename.lowercased().hasSuffix(".png") ? "image/png" : "image/jpeg"
        return "data:\(mime);base64,\(data.base64EncodedString())"
    }

    private func cleanupUnusedPhotoFiles(currentRoot: [String: Any]) {
        var used = photoReferences(in: currentRoot)

        // Keep anything referenced by the previous known-good board as well, so a
        // recovery never loses a photo after a recent edit.
        if let previousData = try? Data(contentsOf: previousBoardFileURL),
           let previousRoot = try? JSONSerialization.jsonObject(with: previousData) as? [String: Any] {
            used.formUnion(photoReferences(in: previousRoot))
        }

        guard let files = try? fileManager.contentsOfDirectory(
            at: photoDirectoryURL,
            includingPropertiesForKeys: nil
        ) else { return }

        for file in files where !used.contains(file.lastPathComponent) {
            try? fileManager.removeItem(at: file)
        }
    }

    private func photoReferences(in root: [String: Any]) -> Set<String> {
        guard let tiles = root["tiles"] as? [Any] else { return [] }
        var result = Set<String>()
        collectPhotoReferences(in: tiles, result: &result)
        return result
    }

    private func collectPhotoReferences(in tiles: [Any], result: inout Set<String>) {
        for item in tiles {
            guard let tile = item as? [String: Any] else { continue }
            if let image = tile["image"] as? String,
               image.hasPrefix(photoPrefix) {
                result.insert(String(image.dropFirst(photoPrefix.count)))
            }
            if let children = tile["children"] as? [Any] {
                collectPhotoReferences(in: children, result: &result)
            }
        }
    }

    private static func looksLikeBoardData(_ data: Data) -> Bool {
        guard let object = try? JSONSerialization.jsonObject(with: data),
              let dictionary = object as? [String: Any],
              dictionary["tiles"] is [Any] else {
            return false
        }
        return true
    }
}
