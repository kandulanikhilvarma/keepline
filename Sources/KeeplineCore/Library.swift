import Foundation

public struct Library: Codable, Equatable, Sendable {
    public var version: Int = 1
    public var lines: [Line] = []
    public var pinnedID: UUID?
    public var intervalMinutes: Int = 60
    public var offset: Int = 0
    public init() {}

    public func validated() throws -> Library {
        guard version == 1, lines.count <= 200, [30, 60, 180].contains(intervalMinutes), offset >= 0,
              Set(lines.map(\.id)).count == lines.count else { throw LineError.invalidBackup }
        var result = self
        result.lines = try lines.map { try $0.validated() }
        if let pinnedID, !lines.contains(where: { $0.id == pinnedID }) { result.pinnedID = nil }
        return result
    }

    public mutating func upsert(_ line: Line) throws {
        let clean = try line.validated()
        if let index = lines.firstIndex(where: { $0.id == clean.id }) { lines[index] = clean }
        else {
            guard lines.count < 200 else { throw LineError.tooManyLines }
            lines.append(clean)
        }
    }

    public mutating func delete(_ id: UUID) {
        lines.removeAll { $0.id == id }
        if pinnedID == id { pinnedID = nil }
    }

    public func selected(at date: Date, calendar: Calendar = .current) -> Line? {
        let active = lines.filter { $0.isActive(at: date, calendar: calendar) }
            .sorted { $0.createdAt == $1.createdAt ? $0.id.uuidString < $1.id.uuidString : $0.createdAt < $1.createdAt }
        guard !active.isEmpty else { return nil }
        if let pinned = active.first(where: { $0.id == pinnedID }) { return pinned }
        let slot = Int(floor(date.timeIntervalSince1970 / Double(intervalMinutes * 60)))
        let normalized = ((slot % active.count) + active.count) % active.count
        return active[(normalized + offset % active.count) % active.count]
    }

    public func timelineDates(from date: Date, calendar: Calendar = .current) -> [Date] {
        let seconds = Double(intervalMinutes * 60)
        let nextSlot = (floor(date.timeIntervalSince1970 / seconds) + 1) * seconds
        var dates = [date]
        for index in 0..<48 { dates.append(Date(timeIntervalSince1970: nextSlot + Double(index) * seconds)) }
        let horizon = dates.last!
        var midnight = calendar.startOfDay(for: date)
        while let next = calendar.date(byAdding: .day, value: 1, to: midnight), next <= horizon {
            dates.append(next); midnight = next
        }
        return Array(Set(dates)).sorted()
    }
}
