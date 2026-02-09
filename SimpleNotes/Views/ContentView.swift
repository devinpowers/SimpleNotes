import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedNote: Note?

    var body: some View {
        NavigationSplitView {
            NoteListView(selectedNote: $selectedNote)
                .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            if let selectedNote {
                NoteEditorView(note: selectedNote)
                    .id(selectedNote.id)
            } else {
                Text("Select or create a note")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
