import Foundation

public enum Period: String, Codable, CaseIterable, Identifiable, Sendable {
    case today, month, year, always, custom
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .today: return "Today"
        case .month: return "This month"
        case .year: return "This year"
        case .always: return "Always"
        case .custom: return "Custom dates"
        }
    }
}

public enum LineError: LocalizedError, Equatable {
    case invalidText, invalidDates, invalidBackup, tooManyLines, unavailable, damaged
    public var errorDescription: String? {
        switch self {
        case .invalidText: return "Use one line of text with 1 to 140 characters."
        case .invalidDates: return "Use valid dates. The end date must follow or match the start date."
        case .invalidBackup: return "This backup is not valid. Your current lines are unchanged."
        case .tooManyLines: return "The library can hold 200 lines. Delete a line before you add another."
        case .unavailable: return "Shared storage is unavailable. Check App Group signing, then reopen the app."
        case .damaged: return "The saved file cannot be read. Restore the previous save or import a backup."
        }
    }
}

public struct Line: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var text: String
    public var period: Period
    public var startDay: String?
    public var endDay: String?
    public var archived: Bool
    public var createdAt: Date

    public init(id: UUID = UUID(), text: String, period: Period = .always,
                startDay: String? = nil, endDay: String? = nil,
                archived: Bool = false, createdAt: Date = Date()) {
        self.id = id; self.text = text; self.period = period
        self.startDay = startDay; self.endDay = endDay
        self.archived = archived; self.createdAt = createdAt
    }

    public func validated() throws -> Line {
        var result = self
        result.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !result.text.isEmpty, result.text.count <= 140,
              !result.text.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }),
              !result.text.contains("\u{2028}"), !result.text.contains("\u{2029}") else { throw LineError.invalidText }
        if period == .always {
            guard startDay == nil, endDay == nil else { throw LineError.invalidDates }
        } else {
            guard let startDay, let endDay, Day.isValid(startDay), Day.isValid(endDay), startDay <= endDay else {
                throw LineError.invalidDates
            }
        }
        return result
    }

    public func isActive(at date: Date, calendar: Calendar = .current) -> Bool {
        guard !archived else { return false }
        let day = Day.key(date, calendar: calendar)
        return (startDay == nil || startDay! <= day) && (endDay == nil || day <= endDay!)
    }
}

public enum Day {
    public static func key(_ date: Date, calendar: Calendar = .current) -> String {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let parts = gregorian.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
    }

    public static func isValid(_ text: String) -> Bool {
        guard text.count == 10 else { return false }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        guard let date = formatter.date(from: text) else { return false }
        return formatter.string(from: date) == text
    }

    public static func bounds(_ period: Period, at date: Date, calendar: Calendar = .current) -> (String?, String?) {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        if period == .always { return (nil, nil) }
        let component: Calendar.Component = period == .month ? .month : period == .year ? .year : .day
        let interval = gregorian.dateInterval(of: component, for: date)!
        return (key(interval.start, calendar: gregorian), key(interval.end.addingTimeInterval(-1), calendar: gregorian))
    }
}
