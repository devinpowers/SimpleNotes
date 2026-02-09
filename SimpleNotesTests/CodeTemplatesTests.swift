import XCTest
@testable import SimpleNotes

final class CodeTemplatesTests: XCTestCase {

    func testAllTemplatesProduceValidMarkdown() {
        for template in CodeTemplates.templates {
            XCTAssertTrue(template.markdown.hasPrefix("```\(template.language)\n"),
                          "Template '\(template.name)' should start with opening fence and language")
            XCTAssertTrue(template.markdown.hasSuffix("\n```"),
                          "Template '\(template.name)' should end with closing fence")
        }
    }

    func testAllTemplatesHaveNonEmptyCode() {
        for template in CodeTemplates.templates {
            XCTAssertFalse(template.code.isEmpty,
                          "Template '\(template.name)' should have non-empty code")
        }
    }

    func testAllTemplatesHaveValidLanguage() {
        for template in CodeTemplates.templates {
            XCTAssertTrue(CodeTemplates.supportedLanguages.contains(template.language),
                          "Template '\(template.name)' language '\(template.language)' should be in supported languages")
        }
    }

    func testSupportedLanguagesHaveDisplayNames() {
        for lang in CodeTemplates.supportedLanguages {
            XCTAssertNotNil(CodeTemplates.displayNames[lang],
                           "Language '\(lang)' should have a display name")
        }
    }

    func testSupportedLanguagesCount() {
        XCTAssertEqual(CodeTemplates.supportedLanguages.count, 12)
    }

    func testTemplateMarkdownCanBeParsed() {
        for template in CodeTemplates.templates {
            let blocks = MarkdownParser.parse(template.markdown)
            XCTAssertEqual(blocks.count, 1,
                          "Template '\(template.name)' markdown should parse to exactly one block")
            if case .code(let language, _) = blocks[0] {
                XCTAssertEqual(language, template.language)
            } else {
                XCTFail("Template '\(template.name)' should parse as a code block")
            }
        }
    }
}
