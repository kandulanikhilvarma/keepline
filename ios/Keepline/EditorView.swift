import SwiftUI
import KeeplineCore

struct EditorView: View {
    let existing: Line?
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var period: Period = .always
    @State private var start = Date()
    @State private var end = Date()
    @State private var error: String?
    @State private var confirmDiscard = false
    @State private var initialText = ""
    @State private var initialPeriod: Period = .always
    @State private var initialStart = Date()
    @State private var initialEnd = Date()
    @State private var renewPeriod = false
    @State private var pin = false
    @State private var initialPin = false
    @State private var draftID = UUID()
    @State private var saving = false
    @FocusState private var textFocused: Bool
    private var dirty: Bool { text != initialText || period != initialPeriod || pin != initialPin || renewPeriod || (period == .custom && (start != initialStart || end != initialEnd)) }

    var body: some View {
        NavigationStack {
            Form {
                Section("Your line") {
                    TextField("For example: Be calm.", text: $text, axis: .vertical)
                        .lineLimit(1...4).focused($textFocused).accessibilityIdentifier("lineText")
                    Text("\(text.count) of 140 characters").font(.caption).foregroundStyle(text.count > 140 ? .red : .secondary)
                    Text("Use your own words. Keep one thought in each line.").font(.footnote).foregroundStyle(.secondary)
                }
                Section("Keep it in sight") {
                    Picker("Period", selection: $period) { ForEach(Period.allCases) { Text($0.title).tag($0) } }
                    if period == .custom {
                        DatePicker("Start date", selection: $start, displayedComponents: .date)
                        DatePicker("End date", selection: $end, displayedComponents: .date)
                    } else if period != .always {
                        let bounds = existing?.period == period && !renewPeriod ? (existing?.startDay, existing?.endDay) : Day.bounds(period, at: Date())
                        Text("\(bounds.0 ?? "") to \(bounds.1 ?? "")").font(.caption)
                        if existing?.period == period { Button("Use the current period") { renewPeriod = true } }
                    }
                    Toggle("Keep this line pinned", isOn: $pin).accessibilityIdentifier("pinLine")
                    Text("An active pinned line stays visible until you unpin it.").font(.footnote).foregroundStyle(.secondary)
                }
                if let error { Section { Text(error).foregroundStyle(.red).accessibilityIdentifier("editorError") } }
            }
            .navigationTitle(existing == nil ? "New line" : "Edit line").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { if dirty { confirmDiscard = true } else { dismiss() } } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saving ? "Save…" : "Save") { save() }.disabled(saving || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text.count > 140)
                        .accessibilityIdentifier("saveLine")
                }
            }
            .interactiveDismissDisabled(dirty)
            .confirmationDialog("Discard these changes?", isPresented: $confirmDiscard) {
                Button("Discard changes", role: .destructive) { dismiss() }
            }
            .onAppear {
                text = existing?.text ?? ""; period = existing?.period ?? .always
                start = parse(existing?.startDay); end = parse(existing?.endDay)
                initialText = text; initialPeriod = period; initialStart = start; initialEnd = end
                pin = existing?.id == model.library.pinnedID && existing != nil; initialPin = pin
            }
        }
    }

    private func parse(_ day: String?) -> Date {
        let formatter = DateFormatter(); formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX"); formatter.dateFormat = "yyyy-MM-dd"
        return day.flatMap { formatter.date(from: $0) } ?? Date()
    }
    private func save() {
        guard !saving else { return }
        saving = true
        var line = existing ?? Line(id: draftID, text: text)
        line.text = text; line.period = period
        if period == .custom { line.startDay = Day.key(start); line.endDay = Day.key(end) }
        else if existing?.period != period || renewPeriod {
            let bounds = Day.bounds(period, at: Date()); line.startDay = bounds.0; line.endDay = bounds.1
        } else if existing == nil { line.startDay = nil; line.endDay = nil }
        if pin && !line.isActive(at: Date()) { error = "Only an active line can stay pinned. Change its period or turn off the pin."; saving = false; return }
        if model.change({ library in
            try library.upsert(line)
            if pin { library.pinnedID = line.id }
            else if library.pinnedID == line.id { library.pinnedID = nil }
        }) { dismiss() }
        else { error = model.error; saving = false }
    }
}
