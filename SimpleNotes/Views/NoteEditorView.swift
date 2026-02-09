import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct NoteEditorView: View {
    @Bindable var note: Note
    @FocusState private var titleFocused: Bool
    @State private var showPreview = false
    @State private var showCodePopover = false

    var body: some View {
        VStack(spacing: 0) {
            TextField("Title", text: $note.title)
                .font(.title)
                .textFieldStyle(.plain)
                .padding([.horizontal, .top])
                .focused($titleFocused)
                .onChange(of: note.title) {
                    note.updatedAt = .now
                }

            Divider()
                .padding(.horizontal)
                .padding(.vertical, 8)

            if showPreview {
                MarkdownPreviewView(markdown: note.body, images: note.imageData)
            } else {
                MarkdownTextEditor(text: $note.body)
                    .padding(.horizontal, 4)
                    .onChange(of: note.body) {
                        note.updatedAt = .now
                    }

                if !note.imageData.isEmpty {
                    Divider().padding(.horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(note.imageData.enumerated()), id: \.offset) { index, data in
                                if let nsImage = NSImage(data: data) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(nsImage: nsImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                            .cornerRadius(6)

                                        Button {
                                            note.imageData.remove(at: index)
                                            note.updatedAt = .now
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white, .red)
                                                .font(.caption)
                                        }
                                        .buttonStyle(.plain)
                                        .offset(x: 4, y: -4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    showPreview.toggle()
                } label: {
                    Label(showPreview ? "Edit" : "Preview", systemImage: showPreview ? "pencil" : "eye")
                }
                .keyboardShortcut("p", modifiers: .command)
                .help(showPreview ? "Edit (Cmd+P)" : "Preview (Cmd+P)")

                Button {
                    showCodePopover.toggle()
                } label: {
                    Label("Insert Code Block", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])
                .help("Insert Code Block (Cmd+Shift+K)")
                .popover(isPresented: $showCodePopover) {
                    InsertCodePopover { insertion in
                        note.body += insertion
                        note.updatedAt = .now
                        showCodePopover = false
                    }
                }

                Button(action: insertImage) {
                    Label("Add Image", systemImage: "photo.badge.plus")
                }
                .help("Insert Image")
            }
        }
    }

    func focusTitle() {
        titleFocused = true
    }

    private func insertImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .gif, .heic]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false

        guard panel.runModal() == .OK else { return }

        for url in panel.urls {
            if let data = try? Data(contentsOf: url) {
                note.imageData.append(data)
                note.body += "\n![image](\(note.imageData.count - 1))\n"
            }
        }
        note.updatedAt = .now
    }
}

private struct InsertCodePopover: View {
    let onInsert: (String) -> Void
    @State private var showTemplates = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Insert Code Block")
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    Section {
                        ForEach(CodeTemplates.supportedLanguages, id: \.self) { lang in
                            Button {
                                onInsert("\n```\(lang)\n\n```\n")
                            } label: {
                                Text(CodeTemplates.displayNames[lang] ?? lang)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                        }
                    } header: {
                        Text("Languages")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.top, 8)
                    }

                    Divider().padding(.vertical, 4)

                    Section {
                        ForEach(CodeTemplates.templates) { template in
                            Button {
                                onInsert("\n\(template.markdown)\n")
                            } label: {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(template.name)
                                    Text(CodeTemplates.displayNames[template.language] ?? template.language)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                        }
                    } header: {
                        Text("Templates")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .frame(width: 220, height: 400)
    }
}
