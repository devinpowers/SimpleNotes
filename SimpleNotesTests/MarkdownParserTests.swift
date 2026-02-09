import XCTest
@testable import SimpleNotes

final class MarkdownParserTests: XCTestCase {

    func testParseCodeBlockWithLanguage() {
        let input = "```swift\nlet x = 1\n```"
        let blocks = MarkdownParser.parse(input)
        XCTAssertEqual(blocks.count, 1)
        XCTAssertEqual(blocks[0], .code(language: "swift", code: "let x = 1"))
    }

    func testParseCodeBlockWithoutLanguage() {
        let input = "```\nsome code\n```"
        let blocks = MarkdownParser.parse(input)
        XCTAssertEqual(blocks.count, 1)
        XCTAssertEqual(blocks[0], .code(language: "", code: "some code"))
    }

    func testParseImagePlaceholder() {
        let input = "![image](0)"
        let blocks = MarkdownParser.parse(input)
        XCTAssertEqual(blocks.count, 1)
        XCTAssertEqual(blocks[0], .imagePlaceholder(index: 0))
    }

    func testParsePlainText() {
        let input = "Hello, world!"
        let blocks = MarkdownParser.parse(input)
        XCTAssertEqual(blocks.count, 1)
        XCTAssertEqual(blocks[0], .text("Hello, world!"))
    }

    func testParseMixedContent() {
        let input = """
        # Title
        Some text here.
        ```python
        def hello():
            print("hi")
        ```
        More text.
        ![image](0)
        Final text.
        """
        let blocks = MarkdownParser.parse(input)
        XCTAssertEqual(blocks.count, 5)
        XCTAssertEqual(blocks[0], .text("# Title\nSome text here."))
        XCTAssertEqual(blocks[1], .code(language: "python", code: "def hello():\n    print(\"hi\")"))
        XCTAssertEqual(blocks[2], .text("More text."))
        XCTAssertEqual(blocks[3], .imagePlaceholder(index: 0))
        XCTAssertEqual(blocks[4], .text("Final text."))
    }

    func testParseUnclosedCodeBlock() {
        let input = "```swift\nlet x = 1\nlet y = 2"
        let blocks = MarkdownParser.parse(input)
        XCTAssertEqual(blocks.count, 1)
        XCTAssertEqual(blocks[0], .code(language: "swift", code: "let x = 1\nlet y = 2"))
    }

    func testParseEmptyInput() {
        let blocks = MarkdownParser.parse("")
        XCTAssertEqual(blocks.count, 0)
    }

    func testParseMultipleCodeBlocks() {
        let input = """
        ```swift
        let a = 1
        ```
        text
        ```python
        x = 2
        ```
        """
        let blocks = MarkdownParser.parse(input)
        XCTAssertEqual(blocks.count, 3)
        XCTAssertEqual(blocks[0], .code(language: "swift", code: "let a = 1"))
        XCTAssertEqual(blocks[1], .text("text"))
        XCTAssertEqual(blocks[2], .code(language: "python", code: "x = 2"))
    }

    func testParseMultipleImages() {
        let input = "![image](0)\n![image](1)\n![image](2)"
        let blocks = MarkdownParser.parse(input)
        XCTAssertEqual(blocks.count, 3)
        XCTAssertEqual(blocks[0], .imagePlaceholder(index: 0))
        XCTAssertEqual(blocks[1], .imagePlaceholder(index: 1))
        XCTAssertEqual(blocks[2], .imagePlaceholder(index: 2))
    }

    func testParseCodeBlockWithEmptyContent() {
        let input = "```javascript\n\n```"
        let blocks = MarkdownParser.parse(input)
        XCTAssertEqual(blocks.count, 1)
        XCTAssertEqual(blocks[0], .code(language: "javascript", code: ""))
    }
}
