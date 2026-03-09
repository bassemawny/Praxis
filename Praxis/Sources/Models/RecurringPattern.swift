import Foundation
import SwiftData

@Model
final class RecurringPattern {
    var frequency: RecurrenceFrequency
    var startDate: Date
    var endDate: Date?
    var clientID: PersistentIdentifier
    var dayOfWeek: Int
    var timeOfDay: Date

    init(
        frequency: RecurrenceFrequency,
        startDate: Date,
        endDate: Date? = nil,
        clientID: PersistentIdentifier,
        dayOfWeek: Int,
        timeOfDay: Date
    ) {
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.clientID = clientID
        self.dayOfWeek = dayOfWeek
        self.timeOfDay = timeOfDay
    }
}

enum RecurrenceFrequency: String, Codable, CaseIterable, Identifiable {
    case weekly
    case biweekly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weekly: return String(localized: "Weekly")
        case .biweekly: return String(localized: "Biweekly")
        }
    }
}
