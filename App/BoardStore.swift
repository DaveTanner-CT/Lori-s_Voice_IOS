import Foundation

final class BoardStore {
    static let shared = BoardStore()

    private let fileManager = FileManager.default

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

        guard Self.looksLikeBoardJSON(json),
              let data = json.data(using: .utf8) else {
            throw CocoaError(.fileWriteCorruptFile)
        }

        // Preserve the last good board before replacing it. This is intentionally
        // local-only and does not require a user action or network connection.
        if fileManager.fileExists(atPath: boardFileURL.path) {
            try? fileManager.removeItem(at: previousBoardFileURL)
            try? fileManager.copyItem(at: boardFileURL, to: previousBoardFileURL)
        }

        try data.write(to: boardFileURL, options: .atomic)
    }

    var storageDescription: String {
        "On this device"
    }

    private func readValidJSON(from url: URL) -> String? {
        guard let data = try? Data(contentsOf: url),
              let json = String(data: data, encoding: .utf8),
              Self.looksLikeBoardJSON(json) else {
            return nil
        }
        return json
    }

    private static func looksLikeBoardJSON(_ json: String) -> Bool {
        guard let data = json.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              let dictionary = object as? [String: Any],
              dictionary["tiles"] is [Any] else {
            return false
        }
        return true
    }
}
