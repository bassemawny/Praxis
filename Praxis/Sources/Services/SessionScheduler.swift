import Foundation

enum SessionScheduler {
    /// Generates dates for recurring sessions from `startDate` up to and including `endDate`.
    static func recurringDates(
        from startDate: Date,
        until endDate: Date,
        frequency: RecurrenceFrequency,
        calendar: Calendar = .current
    ) -> [Date] {
        let weekInterval = frequency == .weekly ? 1 : 2
        var dates: [Date] = []
        var current = startDate

        while current <= endDate {
            dates.append(current)
            guard let next = calendar.date(byAdding: .weekOfYear, value: weekInterval, to: current) else {
                break
            }
            current = next
        }

        return dates
    }
}
