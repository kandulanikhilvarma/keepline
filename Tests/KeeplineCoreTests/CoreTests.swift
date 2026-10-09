import XCTest
@testable import KeeplineCore

final class CoreTests: XCTestCase {
    var utc: Calendar { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(secondsFromGMT: 0)!; return c }
    func date(_ text: String) -> Date { ISO8601DateFormatter().date(from: text)! }

    func testTextValidationAndUnicode() throws {
        XCTAssertEqual(try Line(text: "  Be calm.  ").validated().text, "Be calm.")
        XCTAssertNoThrow(try Line(text: String(repeating: "👨‍👩‍👧‍👦", count: 140)).validated())
        for text in [" ", "a\nb", "a\tb", "a\u{2028}b", String(repeating: "a", count: 141)] {
            XCTAssertThrowsError(try Line(text: text).validated())
        }
    }

    func testCalendarBoundsAndInclusiveDates() throws {
        let now = date("2024-02-15T12:00:00Z")
        let bounds = Day.bounds(.month, at: now, calendar: utc)
        XCTAssertEqual(bounds.0, "2024-02-01"); XCTAssertEqual(bounds.1, "2024-02-29")
        XCTAssertFalse(Day.isValid("2023-02-29"))
        var line = Line(text: "Read", period: .custom, startDay: "2024-02-01", endDay: "2024-02-29")
        XCTAssertTrue(line.isActive(at: date("2024-02-29T23:59:59Z"), calendar: utc))
        XCTAssertFalse(line.isActive(at: date("2024-03-01T00:00:00Z"), calendar: utc))
        line.archived = true; XCTAssertFalse(line.isActive(at: now, calendar: utc))
        line.startDay = "2024-03-01"; XCTAssertThrowsError(try line.validated())
    }

    func testRotationPinAndInactiveFallback() throws {
        var library = Library()
        try library.upsert(Line(text: "First", createdAt: date("2024-01-01T00:00:00Z")))
        try library.upsert(Line(text: "Second", createdAt: date("2024-01-02T00:00:00Z")))
        let now = date("2024-02-01T12:00:00Z")
        XCTAssertNotEqual(library.selected(at: now)?.id, library.selected(at: now.addingTimeInterval(3600))?.id)
        library.pinnedID = library.lines[0].id
        XCTAssertEqual(library.selected(at: now)?.text, "First")
        library.lines[0].archived = true
        XCTAssertEqual(library.selected(at: now)?.text, "Second")
        library.delete(library.lines[0].id); XCTAssertNil(library.pinnedID)
    }

    func testTimelineIncludesMidnightAcrossDST() {
        var india = utc; india.timeZone = TimeZone(identifier: "Asia/Kolkata")!
        let now = date("2024-02-01T17:40:00Z")
        let dates = Library().timelineDates(from: now, calendar: india)
        XCTAssertEqual(dates.first, now)
        XCTAssertTrue(dates.contains(date("2024-02-01T18:30:00Z")))
        XCTAssertEqual(dates, dates.sorted()); XCTAssertEqual(Set(dates).count, dates.count)
        var ny = utc; ny.timeZone = TimeZone(identifier: "America/New_York")!
        XCTAssertTrue(Library().timelineDates(from: date("2024-03-10T04:30:00Z"), calendar: ny)
            .contains(date("2024-03-11T04:00:00Z")))
    }

    func testPersistenceRecoveryAndRejectedImport() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = LibraryStore(directory: directory)
        XCTAssertEqual(try store.load().lines.count, 0)
        var library = Library(); try library.upsert(Line(text: "Be calm.")); try store.save(library)
        XCTAssertEqual(try LibraryStore(directory: directory).load(), library)
        try library.upsert(Line(text: "Read 5 books")); try store.save(library)
        XCTAssertThrowsError(try store.replaceFromBackup(Data("invalid".utf8)))
        XCTAssertEqual(try store.load().lines.count, 2)
        try Data("damaged".utf8).write(to: directory.appendingPathComponent("library.json"))
        XCTAssertThrowsError(try store.load())
        XCTAssertEqual(try store.restorePrevious().lines.count, 1)
        XCTAssertEqual(try store.replaceFromBackup(LibraryStore.encode(library)).lines.count, 2)
    }

    func testBackupLimitsDuplicatesAndIdempotentSave() throws {
        var library = Library(); let line = Line(text: "Same")
        try library.upsert(line); try library.upsert(line); XCTAssertEqual(library.lines.count, 1)
        library.lines.append(line); XCTAssertThrowsError(try library.validated())
        XCTAssertThrowsError(try LibraryStore.decode(Data(repeating: 0, count: 1_048_577)))
        library = Library(); library.intervalMinutes = 1; XCTAssertThrowsError(try library.validated())
        library = Library(); library.lines = (0..<201).map { Line(text: "Line \($0)") }
        XCTAssertThrowsError(try library.validated())
    }
}
