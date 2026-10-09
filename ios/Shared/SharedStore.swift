import Foundation
import KeeplineCore

enum SharedStore {
    static let widgetKind = "KeeplineWidget"
    static func make() throws -> LibraryStore {
        guard let identifier = Bundle.main.object(forInfoDictionaryKey: "KeeplineAppGroup") as? String,
              let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            throw LineError.unavailable
        }
        return LibraryStore(directory: directory)
    }
}
