import SwiftUI
import KeeplineCore
import WidgetKit

@main
struct KeeplineApp: App {
    @StateObject private var model = AppModel()
    var body: some Scene {
        WindowGroup { RootView().environmentObject(model).tint(Color("AccentColor")) }
    }
}

struct EditorRequest: Identifiable {
    let id = UUID()
    var line: Line?
}

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var library = Library()
    @Published var error: String?
    @Published var ready = false
    @Published var editor: EditorRequest?
    @Published var now = Date()
    private var store: LibraryStore?

    func reload() {
        do {
            store = try SharedStore.make()
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--ui-test-reset") {
                library = try store!.replaceFromBackup(LibraryStore.encode(Library()))
            } else { library = try store!.load() }
            #else
            library = try store!.load()
            #endif
            error = nil; ready = true; now = Date()
        } catch { self.error = error.localizedDescription; ready = false }
    }

    @discardableResult
    func change(_ action: (inout Library) throws -> Void) -> Bool {
        guard ready, let store else { error = LineError.unavailable.localizedDescription; return false }
        do {
            var next = library
            try action(&next)
            try store.save(next)
            library = next; error = nil; now = Date()
            WidgetCenter.shared.reloadTimelines(ofKind: SharedStore.widgetKind)
            return true
        } catch { self.error = error.localizedDescription; return false }
    }

    func restore() {
        do {
            let storage = try SharedStore.make()
            library = try storage.restorePrevious(); store = storage; ready = true; error = nil
            WidgetCenter.shared.reloadTimelines(ofKind: SharedStore.widgetKind)
        } catch { self.error = "The previous save is unavailable. Import a backup from Settings." }
    }

    func importBackup(_ data: Data) {
        do {
            let storage = try SharedStore.make()
            library = try storage.replaceFromBackup(data); store = storage; ready = true; error = nil
            WidgetCenter.shared.reloadTimelines(ofKind: SharedStore.widgetKind)
        } catch { self.error = error.localizedDescription }
    }
}

struct RootView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.scenePhase) private var scene
    var body: some View {
        TabView {
            SightView().tabItem { Label("In sight", systemImage: "rectangle") }
            LibraryView().tabItem { Label("Library", systemImage: "text.alignleft") }
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .sheet(item: $model.editor) { request in EditorView(existing: request.line) }
        .task { model.reload() }
        .onChange(of: scene) { _, phase in if phase == .active { model.reload() } }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { model.now = $0 }
        .onOpenURL { url in
            guard url.scheme == "keepline", url.host == "line", let id = UUID(uuidString: url.lastPathComponent),
                  let line = model.library.lines.first(where: { $0.id == id }) else { return }
            model.editor = EditorRequest(line: line)
        }
    }
}

struct StorageNotice: View {
    @EnvironmentObject private var model: AppModel
    var body: some View {
        if let error = model.error {
            Section {
                Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(.red)
                Button("Retry") { model.reload() }
                if !model.ready { Button("Restore previous save") { model.restore() } }
            }
        }
    }
}

struct SightView: View {
    @EnvironmentObject private var model: AppModel
    var body: some View {
        NavigationStack {
            List {
                StorageNotice()
                Section {
                    LineCard(line: model.library.selected(at: model.now), failure: !model.ready)
                        .padding(20).frame(minHeight: 180)
                        .listRowBackground(Color("WidgetPaper"))
                } header: { Text("Widget preview") }
                if model.ready && model.library.lines.isEmpty {
                    Section {
                        Text("A word. A goal. A line to come back to.").font(.title2)
                        Text("Write your own line, then add Keepline to your home screen.")
                        Button("Save your first line") { model.editor = EditorRequest() }
                            .accessibilityIdentifier("firstLine")
                    }
                } else if model.ready && model.library.selected(at: model.now) == nil {
                    Section { Text("No lines are active today. Change a period or add a new line.") }
                }
                Section {
                    Button("Next line", systemImage: "arrow.right") {
                        model.change { $0.pinnedID = nil; $0.offset = $0.offset == Int.max ? 0 : $0.offset + 1 }
                    }.disabled(!model.ready || model.library.lines.filter { $0.isActive(at: model.now) }.count < 2)
                    Text(model.library.pinnedID == nil ? "Active lines rotate about every \(model.library.intervalMinutes) minutes." : "Your active pinned line stays in sight.")
                    Text("iOS controls widget updates. A line does not change on every unlock.").font(.footnote).foregroundStyle(.secondary)
                }
                Section("Add the rectangular widget") {
                    Text("Touch and hold the home screen. Tap Edit, then Add Widget. Search for Keepline. Choose the rectangular widget.")
                    Text("On older iOS versions, tap the plus button to add a widget.").font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("In sight")
            .toolbar { Button("Add line", systemImage: "plus") { model.editor = EditorRequest() }.disabled(!model.ready) }
        }
    }
}

struct LibraryView: View {
    @EnvironmentObject private var model: AppModel
    @State private var filter = "Current"
    @State private var deleteID: UUID?
    private var lines: [Line] { Array(model.library.lines.filter { filter == "Archived" ? $0.archived : !$0.archived }.reversed()) }
    var body: some View {
        NavigationStack {
            List {
                StorageNotice()
                Picker("Show lines", selection: $filter) {
                    Text("Current").tag("Current"); Text("Archived").tag("Archived")
                }.pickerStyle(.segmented)
                if lines.isEmpty { ContentUnavailableView("No lines here", systemImage: "text.alignleft", description: Text("Add a line or change the filter.")) }
                ForEach(lines) { line in
                    Button { model.editor = EditorRequest(line: line) } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(line.text).font(.body).foregroundStyle(.primary)
                            Text(status(line)).font(.caption).foregroundStyle(.secondary)
                            if model.library.pinnedID == line.id { Label("Pinned", systemImage: "pin.fill").font(.caption) }
                        }.padding(.vertical, 6)
                    }
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") { model.editor = EditorRequest(line: line) }
                        Button(model.library.pinnedID == line.id ? "Unpin" : "Pin", systemImage: "pin") {
                            model.change { $0.pinnedID = $0.pinnedID == line.id ? nil : line.id }
                        }.disabled(!line.isActive(at: model.now))
                        Button(line.archived ? "Restore" : "Archive", systemImage: "archivebox") { archive(line) }
                        Button("Delete", systemImage: "trash", role: .destructive) { deleteID = line.id }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", role: .destructive) { deleteID = line.id }
                        Button(line.archived ? "Restore" : "Archive") { archive(line) }.tint(.orange)
                    }
                }
            }.navigationTitle("Your lines")
                .toolbar { Button("Add line", systemImage: "plus") { model.editor = EditorRequest() }.disabled(!model.ready) }
                .confirmationDialog("Delete this line?", isPresented: Binding(get: { deleteID != nil }, set: { if !$0 { deleteID = nil } })) {
                    Button("Delete line", role: .destructive) { if let id = deleteID { model.change { $0.delete(id) } }; deleteID = nil }
                } message: { Text("This removes the line from the library and future widget timelines.") }
        }
    }
    private func archive(_ line: Line) {
        model.change { library in
            guard let index = library.lines.firstIndex(where: { $0.id == line.id }) else { return }
            library.lines[index].archived.toggle()
            if library.lines[index].archived && library.pinnedID == line.id { library.pinnedID = nil }
        }
    }
    private func status(_ line: Line) -> String {
        let activity = line.archived ? "Archived" : line.isActive(at: model.now) ? "Active" : "Outside its period"
        return "\(line.period.title) · \(activity)" + (line.endDay.map { " · until \($0)" } ?? "")
    }
}
