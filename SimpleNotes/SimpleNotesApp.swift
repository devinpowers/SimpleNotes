import SwiftUI
import SwiftData

@main
struct SimpleNotesApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([Note.self])
            let config = ModelConfiguration(schema: schema)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Schema changed — delete old store and retry
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let storeURL = appSupport.appendingPathComponent("default.store")
            try? FileManager.default.removeItem(at: storeURL)
            // Also remove related files
            for suffix in ["-shm", "-wal"] {
                try? FileManager.default.removeItem(at: storeURL.appendingPathExtension(suffix))
            }
            container = try! ModelContainer(for: Schema([Note.self]))
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
        .commands {
            NoteCommands()
        }
    }
}

private struct NoteCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .newItem) {
            // Cmd+N is handled via NoteListView toolbar button
            // Additional commands can be added here
        }
    }
}
