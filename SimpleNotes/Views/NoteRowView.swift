import SwiftUI

struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(.headline)
                    .lineLimit(1)
            }

            HStack {
                Text(note.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(preview)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }

    private var preview: String {
        let firstLine = note.body.split(separator: "\n", maxSplits: 1).first.map(String.init) ?? ""
        return firstLine
    }
}
