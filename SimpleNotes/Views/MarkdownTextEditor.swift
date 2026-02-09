import SwiftUI
import AppKit

struct MarkdownTextEditor: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = .labelColor
        textView.backgroundColor = .clear
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.delegate = context.coordinator

        context.coordinator.textView = textView
        textView.string = text
        context.coordinator.applyHighlighting(textView)

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        if textView.string != text {
            let selectedRanges = textView.selectedRanges
            textView.string = text
            context.coordinator.applyHighlighting(textView)
            textView.selectedRanges = selectedRanges
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownTextEditor
        weak var textView: NSTextView?

        // Colors for syntax highlighting inside code blocks
        private let keywordColor = NSColor.systemPurple
        private let stringColor = NSColor.systemRed
        private let commentColor = NSColor.systemGreen
        private let languageColor = NSColor.systemOrange

        private static let keywords: Set<String> = [
            "func", "let", "var", "if", "else", "for", "while", "return",
            "import", "class", "struct", "def", "const", "function",
            "enum", "switch", "case", "break", "continue", "guard",
            "self", "true", "false", "nil", "null", "undefined",
            "async", "await", "try", "catch", "throw", "fn", "pub",
            "mut", "impl", "trait", "type", "interface", "export",
            "from", "select", "where", "insert", "update", "delete",
            "create", "drop", "table", "index", "join", "on",
            "print", "println", "echo", "fmt"
        ]

        init(_ parent: MarkdownTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            applyHighlighting(textView)
        }

        func applyHighlighting(_ textView: NSTextView) {
            let storage = textView.textStorage!
            let fullRange = NSRange(location: 0, length: storage.length)
            let text = storage.string

            // Reset to default
            storage.beginEditing()
            storage.setAttributes([
                .font: NSFont.systemFont(ofSize: 14),
                .foregroundColor: NSColor.labelColor
            ], range: fullRange)

            let lines = text.components(separatedBy: "\n")
            var offset = 0
            var inCodeBlock = false
            var codeBlockStart = 0

            for line in lines {
                let lineRange = NSRange(location: offset, length: line.count)

                if line.hasPrefix("```") {
                    // Fence line styling
                    storage.addAttributes([
                        .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
                        .foregroundColor: NSColor.secondaryLabelColor
                    ], range: lineRange)

                    if inCodeBlock {
                        // Closing fence — apply background to the whole block
                        let blockRange = NSRange(location: codeBlockStart, length: offset + line.count - codeBlockStart)
                        storage.addAttribute(.backgroundColor, value: NSColor.controlBackgroundColor, range: blockRange)
                        inCodeBlock = false
                    } else {
                        inCodeBlock = true
                        codeBlockStart = offset

                        // Highlight language identifier
                        let langText = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                        if !langText.isEmpty {
                            let langStart = offset + 3
                            let langRange = NSRange(location: langStart, length: line.count - 3)
                            storage.addAttribute(.foregroundColor, value: languageColor, range: langRange)
                        }
                    }
                } else if inCodeBlock {
                    storage.addAttributes([
                        .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
                        .foregroundColor: NSColor.labelColor
                    ], range: lineRange)

                    // Syntax highlighting inside code blocks
                    highlightCodeLine(line, offset: offset, storage: storage)
                } else {
                    // Headers
                    if line.hasPrefix("### ") {
                        storage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 16), range: lineRange)
                    } else if line.hasPrefix("## ") {
                        storage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 18), range: lineRange)
                    } else if line.hasPrefix("# ") {
                        storage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 22), range: lineRange)
                    }

                    // Inline code: `code`
                    highlightPattern("`([^`]+)`", in: line, offset: offset, storage: storage, attributes: [
                        .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
                        .backgroundColor: NSColor.controlBackgroundColor
                    ])

                    // Bold: **text** or __text__
                    highlightPattern("(\\*\\*|__)(.+?)(\\*\\*|__)", in: line, offset: offset, storage: storage, attributes: [
                        .font: NSFont.boldSystemFont(ofSize: 14)
                    ])

                    // Italic: *text* or _text_ (but not ** or __)
                    highlightPattern("(?<![\\*_])[\\*_]([^\\*_]+)[\\*_](?![\\*_])", in: line, offset: offset, storage: storage, attributes: [
                        .font: NSFont(descriptor: NSFont.systemFont(ofSize: 14).fontDescriptor.withSymbolicTraits(.italic), size: 14)!
                    ])
                }

                offset += line.count + 1 // +1 for newline
            }

            // If we ended inside a code block, still apply background
            if inCodeBlock {
                let blockRange = NSRange(location: codeBlockStart, length: storage.length - codeBlockStart)
                storage.addAttribute(.backgroundColor, value: NSColor.controlBackgroundColor, range: blockRange)
            }

            storage.endEditing()
        }

        private func highlightCodeLine(_ line: String, offset: Int, storage: NSTextStorage) {
            // Comments: // or #
            if let commentRange = findComment(in: line) {
                let nsRange = NSRange(location: offset + commentRange.lowerBound, length: commentRange.count)
                storage.addAttribute(.foregroundColor, value: commentColor, range: nsRange)
                // Don't highlight keywords/strings inside comments
                let beforeComment = String(line.prefix(commentRange.lowerBound))
                highlightKeywordsAndStrings(beforeComment, offset: offset, storage: storage)
                return
            }

            highlightKeywordsAndStrings(line, offset: offset, storage: storage)
        }

        private func findComment(in line: String) -> Range<Int>? {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Line starting with # (but not #! shebang)
            if trimmed.hasPrefix("#") && !trimmed.hasPrefix("#!") {
                if let idx = line.firstIndex(of: "#") {
                    let start = line.distance(from: line.startIndex, to: idx)
                    return start..<line.count
                }
            }
            // // comment
            var inString = false
            var stringChar: Character = "\""
            let chars = Array(line)
            for i in 0..<chars.count {
                if !inString {
                    if chars[i] == "\"" || chars[i] == "'" {
                        inString = true
                        stringChar = chars[i]
                    } else if chars[i] == "/" && i + 1 < chars.count && chars[i + 1] == "/" {
                        return i..<line.count
                    }
                } else {
                    if chars[i] == stringChar && (i == 0 || chars[i - 1] != "\\") {
                        inString = false
                    }
                }
            }
            return nil
        }

        private func highlightKeywordsAndStrings(_ line: String, offset: Int, storage: NSTextStorage) {
            // Strings: "..." or '...'
            highlightPattern("\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", in: line, offset: offset, storage: storage, attributes: [
                .foregroundColor: stringColor
            ])
            highlightPattern("'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'", in: line, offset: offset, storage: storage, attributes: [
                .foregroundColor: stringColor
            ])

            // Keywords: word boundary match
            highlightPattern("\\b(?:func|let|var|if|else|for|while|return|import|class|struct|def|const|function|enum|switch|case|break|continue|guard|self|true|false|nil|null|undefined|async|await|try|catch|throw|fn|pub|mut|impl|trait|type|interface|export|from|select|where|insert|update|delete|create|drop|table|index|join|on|print|println|echo|fmt)\\b", in: line, offset: offset, storage: storage, attributes: [
                .foregroundColor: keywordColor
            ])
        }

        private func highlightPattern(_ pattern: String, in line: String, offset: Int, storage: NSTextStorage, attributes: [NSAttributedString.Key: Any]) {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
            let lineRange = NSRange(location: 0, length: line.count)
            for match in regex.matches(in: line, range: lineRange) {
                let matchRange = NSRange(location: match.range.location + offset, length: match.range.length)
                storage.addAttributes(attributes, range: matchRange)
            }
        }
    }
}
