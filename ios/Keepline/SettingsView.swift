import SwiftUI
import UniformTypeIdentifiers
import KeeplineCore

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data = Data()
    init(data: Data = Data()) { self.data = data }
    init(configuration: ReadConfiguration) throws { data = configuration.file.regularFileContents ?? Data() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var export = false
    @State private var importer = false
    @State private var document = BackupDocument()
    @State private var pending: Data?
    @State private var notice: String?
    var body: some View {
        NavigationStack {
            Form {
                StorageNotice()
                Section("Widget rotation") {
                    Picker("Change lines about every", selection: Binding(get: { model.library.intervalMinutes }, set: { value in model.change { $0.intervalMinutes = value } })) {
                        Text("30 minutes").tag(30); Text("1 hour").tag(60); Text("3 hours").tag(180)
                    }.disabled(!model.ready)
                    Text("A pinned line stays visible. Expired and archived lines leave the rotation.").font(.footnote)
                    Text("iOS can delay updates to save battery. Open Keepline after a time-zone change.").font(.footnote).foregroundStyle(.secondary)
                }
                Section("Your data") {
                    Button("Export backup") {
                        do { document = BackupDocument(data: try LibraryStore.encode(model.library)); export = true }
                        catch { notice = error.localizedDescription }
                    }.disabled(!model.ready)
                    Button("Import backup") { importer = true }
                    Text("Backups contain your words in plain text. Keep each file in a private location.").font(.footnote).foregroundStyle(.secondary)
                    if let notice { Text(notice).accessibilityIdentifier("backupNotice") }
                }
                Section("Privacy") {
                    Text("Your lines stay on this iPhone. Keepline uses no account, advertising, analytics, or remote database.")
                    Text("The home-screen widget displays your words to anyone who can see your screen.").font(.footnote).foregroundStyle(.secondary)
                    Link("Privacy and setup", destination: URL(string: "https://keepline.vercel.app/#privacy")!)
                }
                Section { Text("Keepline 1.0.0"); Text("Your own words, in sight.").foregroundStyle(.secondary) }
            }.navigationTitle("Settings")
                .fileExporter(isPresented: $export, document: document, contentType: .json, defaultFilename: "keepline-backup") { result in
                    switch result { case .success: notice = "Backup exported."; case .failure(let error): notice = error.localizedDescription }
                }
                .fileImporter(isPresented: $importer, allowedContentTypes: [.json]) { result in
                    do {
                        let url = try result.get()
                        let access = url.startAccessingSecurityScopedResource()
                        defer { if access { url.stopAccessingSecurityScopedResource() } }
                        let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                        guard size <= 1_048_576 else { throw LineError.invalidBackup }
                        let data = try Data(contentsOf: url); _ = try LibraryStore.decode(data); pending = data
                    } catch { notice = error.localizedDescription }
                }
                .confirmationDialog("Replace your library?", isPresented: Binding(get: { pending != nil }, set: { if !$0 { pending = nil } })) {
                    Button("Replace from backup", role: .destructive) {
                        if let pending { model.importBackup(pending); notice = model.error ?? "Backup imported." }
                        pending = nil
                    }
                } message: { Text("This replaces all current lines and rotation settings. Export a backup first.") }
        }
    }
}
