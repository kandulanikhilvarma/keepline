import Foundation

public final class LibraryStore {
    private let url: URL
    private var previousURL: URL { url.appendingPathExtension("previous") }
    public init(directory: URL) { url = directory.appendingPathComponent("library.json") }

    public func load() throws -> Library {
        guard FileManager.default.fileExists(atPath: url.path) else { return Library() }
        do { return try Self.decode(Data(contentsOf: url)) }
        catch { throw LineError.damaged }
    }

    public func save(_ library: Library) throws {
        let clean = try library.validated()
        let data = try Self.encode(clean)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        if FileManager.default.fileExists(atPath: url.path) {
            let previous = try Data(contentsOf: url)
            _ = try Self.decode(previous)
            try write(previous, to: previousURL)
        }
        try write(data, to: url)
    }

    public func restorePrevious() throws -> Library {
        let data = try Data(contentsOf: previousURL)
        let library = try Self.decode(data)
        try write(data, to: url)
        return library
    }

    public func replaceFromBackup(_ data: Data) throws -> Library {
        let library = try Self.decode(data)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        // Preserve a readable current file before replacement.
        if let current = try? Data(contentsOf: url), (try? Self.decode(current)) != nil { try write(current, to: previousURL) }
        try write(try Self.encode(library), to: url)
        return library
    }

    private func write(_ data: Data, to target: URL) throws {
        #if os(iOS)
        try data.write(to: target, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        #else
        try data.write(to: target, options: .atomic)
        #endif
    }

    public static func encode(_ library: Library) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(library.validated())
    }

    public static func decode(_ data: Data) throws -> Library {
        guard data.count <= 1_048_576 else { throw LineError.invalidBackup }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Library.self, from: data).validated()
        } catch { throw LineError.invalidBackup }
    }
}
