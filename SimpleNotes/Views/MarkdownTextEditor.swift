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
                    }
                } else if inCodeBlock {
                    storage.addAttributes([
                        .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
                        .foregroundColor: NSColor.labelColor
                    ], range: lineRange)
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
