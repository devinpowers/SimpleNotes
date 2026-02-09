import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date
    var isPinned: Bool
    @Attribute(.externalStorage) var imageData: [Data]

    init(title: String = "", body: String = "", createdAt: Date = .now, updatedAt: Date = .now, isPinned: Bool = false, imageData: [Data] = []) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
        self.imageData = imageData
    }
}
