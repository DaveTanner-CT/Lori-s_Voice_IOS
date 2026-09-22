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

    func loadJSON() -> String? {
        guard let data = try? Data(contentsOf: boardFileURL) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func save(json: String) throws {
        try fileManager.createDirectory(
            at: boardDirectoryURL,
            withIntermediateDirectories: true
        )
        guard let data = json.data(using: .utf8) else {
            throw CocoaError(.fileWriteInapplicableStringEncoding)
        }
        try data.write(to: boardFileURL, options: .atomic)
    }
}
