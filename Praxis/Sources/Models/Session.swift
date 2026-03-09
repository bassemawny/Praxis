import Foundation
import SwiftData

@Model
final class Session {
    var client: Client?
    var date: Date
    var status: SessionStatus
    var noteContent: String?
    var templateType: NoteTemplate?
    var createdAt: Date
    var calendarEventIdentifier: String?

    @Relationship(deleteRule: .cascade, inverse: \Attachment.session)
    var attachments: [Attachment]

    @Relationship(deleteRule: .cascade, inverse: \Reminder.session)
    var reminders: [Reminder]

    init(
        client: Client,
        date: Date,
        status: SessionStatus = .upcoming,
        noteContent: String? = nil,
        templateType: NoteTemplate? = nil
    ) {
        self.client = client
        self.date = date
        self.status = status
        self.noteContent = noteContent
        self.templateType = templateType
        self.createdAt = .now
        self.attachments = []
        self.reminders = []
    }
}

enum SessionStatus: String, Codable, CaseIterable, Identifiable {
    case upcoming
    case completed
    case cancelled
    case noShow

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .upcoming: return String(localized: "Upcoming")
        case .completed: return String(localized: "Completed")
        case .cancelled: return String(localized: "Cancelled")
        case .noShow: return String(localized: "No Show")
        }
    }
}

enum NoteTemplate: String, Codable, CaseIterable, Identifiable {
    case soap
    case dap

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .soap: return "SOAP"
        case .dap: return "DAP"
        }
    }

    var templateContent: String {
        switch self {
        case .soap:
            return """
Subjective:


Objective:


Assessment:


Plan:

"""
        case .dap:
            return """
Data:


Assessment:


Plan:

"""
        }
    }
}
