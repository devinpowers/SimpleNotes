import SwiftUI

struct MarkdownPreviewView: View {
    let markdown: String
    let images: [Data]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
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
        VStack(alignment: .leading, spacing: 4) {
            if !language.isEmpty {
                Text(language)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3)))
    }

    private enum Block {
        case text(String)
        case code(language: String, code: String)
        case imagePlaceholder(index: Int)
    }

    private var blocks: [Block] {
        var result: [Block] = []
        var currentText = ""
        let lines = markdown.components(separatedBy: "\n")
        var i = 0

        while i < lines.count {
            let line = lines[i]

            // Check for image placeholder: ![image](index)
            if line.hasPrefix("![image](") && line.hasSuffix(")") {
                let inner = line.dropFirst(9).dropLast(1)
                if let idx = Int(inner) {
                    if !currentText.isEmpty {
                        result.append(.text(currentText.trimmingCharacters(in: .newlines)))
                        currentText = ""
                    }
                    result.append(.imagePlaceholder(index: idx))
                    i += 1
                    continue
                }
            }

            // Check for fenced code block
            if line.hasPrefix("```") {
                if !currentText.isEmpty {
                    result.append(.text(currentText.trimmingCharacters(in: .newlines)))
                    currentText = ""
                }
                let language = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                i += 1
                while i < lines.count && !lines[i].hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }
                result.append(.code(language: language, code: codeLines.joined(separator: "\n")))
                i += 1 // skip closing ```
                continue
            }

            currentText += (currentText.isEmpty ? "" : "\n") + line
            i += 1
        }

        if !currentText.isEmpty {
            result.append(.text(currentText.trimmingCharacters(in: .newlines)))
        }

        return result
    }
}
