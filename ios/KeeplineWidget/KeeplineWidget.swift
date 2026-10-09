import WidgetKit
import SwiftUI
import KeeplineCore

struct LineEntry: TimelineEntry {
    let date: Date
    let line: Line?
    var failure = false
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> LineEntry {
        LineEntry(date: Date(), line: Line(text: "Be calm."))
    }
    func getSnapshot(in context: Context, completion: @escaping (LineEntry) -> Void) {
        if context.isPreview { completion(placeholder(in: context)); return }
        completion(entry(at: Date()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<LineEntry>) -> Void) {
        let now = Date()
        do {
            let library = try SharedStore.make().load()
            let dates = library.timelineDates(from: now)
            completion(Timeline(entries: dates.map { LineEntry(date: $0, line: library.selected(at: $0)) }, policy: .atEnd))
        } catch {
            completion(Timeline(entries: [LineEntry(date: now, line: nil, failure: true)], policy: .after(now.addingTimeInterval(1800))))
        }
    }
    private func entry(at date: Date) -> LineEntry {
        do { return LineEntry(date: date, line: try SharedStore.make().load().selected(at: date)) }
        catch { return LineEntry(date: date, line: nil, failure: true) }
    }
}

@main
struct KeeplineWidget: Widget {
    let kind = SharedStore.widgetKind
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LineCard(line: entry.line, failure: entry.failure)
                .containerBackground(Color("WidgetPaper"), for: .widget)
                .widgetURL(URL(string: entry.line.map { "keepline://line/\($0.id.uuidString)" } ?? "keepline://home"))
        }
        .configurationDisplayName("Keepline")
        .description("Your own words, in sight. Active lines rotate throughout the day.")
        .supportedFamilies([.systemMedium])
    }
}
