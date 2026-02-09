import SwiftUI

struct MarkdownPreviewView: View {
    let markdown: String
    let images: [Data]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(MarkdownParser.parse(markdown).enumerated()), id: \.offset) { _, block in
                    switch block {
                    case .code(let language, let code):
                        codeBlock(language: language, code: code)
                    case .imagePlaceholder(let index):
                        if index < images.count, let nsImage = NSImage(data: images[index]) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 500)
                                .cornerRadius(8)
                        }
                    case .text(let text):
                        if let attributed = try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                            Text(attributed)
                                .textSelection(.enabled)
                        } else {
                            Text(text)
                                .textSelection(.enabled)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func codeBlock(language: String, code: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with language badge and copy button
            HStack {
                if !language.isEmpty {
                    Text(CodeTemplates.displayNames[language] ?? language)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundStyle(Color.accentColor)
                        .cornerRadius(4)
                }
                Spacer()
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(code, forType: .string)
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Code with line numbers
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    let lines = code.components(separatedBy: "\n")
                    // Line numbers
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(1...max(lines.count, 1), id: \.self) { num in
                            Text("\(num)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.tertiary)
                                .frame(height: 18)
                        }
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 8)

                    Divider()
                        .padding(.vertical, 2)

                    // Code content
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                            Text(line.isEmpty ? " " : line)
                                .font(.system(.body, design: .monospaced))
                                .textSelection(.enabled)
                                .frame(height: 18, alignment: .leading)
                        }
                    }
                    .padding(.leading, 8)
                    .padding(.trailing, 10)
                }
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3)))
    }
}
