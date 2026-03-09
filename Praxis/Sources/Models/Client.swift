import Foundation
import SwiftData

@Model
final class Client {
    var name: String
    var age: Int?
    var gender: Gender?
    var phone: String?
    var email: String?
    var notes: String?
    var isArchived: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Session.client)
    var sessions: [Session]

    @Relationship(deleteRule: .cascade, inverse: \Reminder.client)
    var reminders: [Reminder]

    init(
        name: String,
        age: Int? = nil,
        gender: Gender? = nil,
        phone: String? = nil,
        email: String? = nil,
        notes: String? = nil,
        isArchived: Bool = false
    ) {
        self.name = name
        self.age = age
        self.gender = gender
        self.phone = phone
        self.email = email
        self.notes = notes
        self.isArchived = isArchived
        self.createdAt = .now
        self.sessions = []
        self.reminders = []
    }

    var activeSessions: [Session] {
        sessions.filter { $0.status != .cancelled }
            .sorted { $0.date > $1.date }
    }

    var upcomingSessions: [Session] {
        sessions.filter { $0.status == .upcoming && $0.date > .now }
            .sorted { $0.date < $1.date }
    }

    var pastSessions: [Session] {
        sessions.filter { $0.status != .upcoming || $0.date <= .now }
            .sorted { $0.date > $1.date }
    }
}

enum Gender: String, Codable, CaseIterable, Identifiable {
    case male
    case female
    case nonBinary
    case other
    case preferNotToSay

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .male: return String(localized: "Male")
        case .female: return String(localized: "Female")
        case .nonBinary: return String(localized: "Non-binary")
        case .other: return String(localized: "Other")
        case .preferNotToSay: return String(localized: "Prefer not to say")
        }
    }
}
