import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.updatedAt, order: .reverse) private var notes: [Note]
    @Binding var selectedNote: Note?
    @State private var searchText = ""

    private var pinnedNotes: [Note] {
        filteredNotes.filter { $0.isPinned }
    }

    private var unpinnedNotes: [Note] {
        filteredNotes.filter { !$0.isPinned }
    }

    var body: some View {
        List(selection: $selectedNote) {
            if !pinnedNotes.isEmpty {
                Section("Pinned") {
                    ForEach(pinnedNotes) { note in
                        NoteRowView(note: note)
                            .tag(note)
                            .contextMenu { noteContextMenu(for: note) }
                    }
                    .onDelete { offsets in deleteNotes(from: pinnedNotes, at: offsets) }
                }
            }

            Section(pinnedNotes.isEmpty ? "" : "Notes") {
                ForEach(unpinnedNotes) { note in
                    NoteRowView(note: note)
                        .tag(note)
                        .contextMenu { noteContextMenu(for: note) }
                }
                .onDelete { offsets in deleteNotes(from: unpinnedNotes, at: offsets) }
            }
        }
        .searchable(text: $searchText, prompt: "Search notes")
        .toolbar {
            ToolbarItem {
                Button(action: createNote) {
                    Label("New Note", systemImage: "square.and.pencil")
                }
            }
        }
    }

    @ViewBuilder
    private func noteContextMenu(for note: Note) -> some View {
        Button {
            note.isPinned.toggle()
            note.updatedAt = .now
        } label: {
            Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
        }
        Button(role: .destructive) {
            if selectedNote == note { selectedNote = nil }
            modelContext.delete(note)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private var filteredNotes: [Note] {
        if searchText.isEmpty { return notes }
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.body.localizedCaseInsensitiveContains(searchText)
        }
    }

    func createNote() {
        let note = Note()
        modelContext.insert(note)
        selectedNote = note
    }

    private func deleteNotes(from source: [Note], at offsets: IndexSet) {
        for index in offsets {
            let note = source[index]
            if selectedNote == note { selectedNote = nil }
            modelContext.delete(note)
        }
    }
}
