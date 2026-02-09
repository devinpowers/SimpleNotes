import Foundation

enum Block: Equatable {
    case text(String)
    case code(language: String, code: String)
    case imagePlaceholder(index: Int)
}

struct MarkdownParser {
    static func parse(_ markdown: String) -> [Block] {
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
