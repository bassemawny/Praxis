import Foundation
import SwiftData

@Model
final class Attachment {
    var type: AttachmentType
    var fileName: String
    @Attribute(.externalStorage) var data: Data
    var createdAt: Date
    var session: Session?

    init(
        type: AttachmentType,
        fileName: String,
        data: Data,
        session: Session? = nil
    ) {
        self.type = type
        self.fileName = fileName
        self.data = data
        self.session = session
        self.createdAt = .now
    }
}

enum AttachmentType: String, Codable {
    case image
    case voiceNote
}
