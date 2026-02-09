import XCTest
@testable import SimpleNotes

final class NoteModelTests: XCTestCase {

    func testNoteDefaultInitialization() {
        let note = Note()
        XCTAssertEqual(note.title, "")
        XCTAssertEqual(note.body, "")
        XCTAssertFalse(note.isPinned)
        XCTAssertTrue(note.imageData.isEmpty)
    }

    func testNoteCustomInitialization() {
        let date = Date(timeIntervalSince1970: 1000)
        let note = Note(
            title: "Test Title",
            body: "Test Body",
            createdAt: date,
            updatedAt: date,
            isPinned: true,
            imageData: [Data([0x01, 0x02])]
        )
        XCTAssertEqual(note.title, "Test Title")
        XCTAssertEqual(note.body, "Test Body")
        XCTAssertEqual(note.createdAt, date)
        XCTAssertEqual(note.updatedAt, date)
        XCTAssertTrue(note.isPinned)
        XCTAssertEqual(note.imageData.count, 1)
    }

    func testNoteHasUniqueID() {
        let note1 = Note()
        let note2 = Note()
        XCTAssertNotEqual(note1.id, note2.id)
    }

    func testNoteCreatedAtDefaultsToNow() {
        let before = Date.now
        let note = Note()
        let after = Date.now
        XCTAssertGreaterThanOrEqual(note.createdAt, before)
        XCTAssertLessThanOrEqual(note.createdAt, after)
    }
}
