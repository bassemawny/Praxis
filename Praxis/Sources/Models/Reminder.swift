import Foundation
import SwiftData

@Model
final class Reminder {
    var title: String
    var isCompleted: Bool
    var dueDate: Date?
    var notificationLeadTime: NotificationLeadTime?
    var notificationIdentifier: String?
    var client: Client?
    var session: Session?
    var createdAt: Date

    init(
        title: String,
        dueDate: Date? = nil,
        notificationLeadTime: NotificationLeadTime? = nil,
        client: Client? = nil,
        session: Session? = nil
    ) {
        self.title = title
        self.isCompleted = false
        self.dueDate = dueDate
        self.notificationLeadTime = notificationLeadTime
        self.client = client
        self.session = session
        self.createdAt = .now
    }
}

enum NotificationLeadTime: String, Codable, CaseIterable, Identifiable {
    case oneHour
    case sixHours
    case twelveHours
    case twentyFourHours

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oneHour: return String(localized: "1 hour before")
        case .sixHours: return String(localized: "6 hours before")
        case .twelveHours: return String(localized: "12 hours before")
        case .twentyFourHours: return String(localized: "24 hours before")
        }
    }

    var timeInterval: TimeInterval {
        switch self {
        case .oneHour: return 3600
        case .sixHours: return 21600
        case .twelveHours: return 43200
        case .twentyFourHours: return 86400
        }
    }
}
