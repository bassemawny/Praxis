import Testing
import Foundation
@testable import Praxis

@Suite("Session Scheduler Tests")
struct SessionSchedulerTests {

    // Fixed calendar to avoid timezone issues
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 10) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    // MARK: - Weekly recurrence

    @Test("Weekly recurrence generates correct number of sessions")
    func weekly_correctCount() {
        let start = date(2026, 3, 2) // Monday
        let end = date(2026, 3, 30)  // 4 weeks + 2 days later

        let dates = SessionScheduler.recurringDates(
            from: start, until: end, frequency: .weekly, calendar: calendar
        )

        // Mar 2, 9, 16, 23, 30 = 5 sessions
        #expect(dates.count == 5)
    }

    @Test("Weekly recurrence dates are exactly 7 days apart")
    func weekly_sevenDayIntervals() {
        let start = date(2026, 1, 5)
        let end = date(2026, 2, 2)

        let dates = SessionScheduler.recurringDates(
            from: start, until: end, frequency: .weekly, calendar: calendar
        )

        for i in 1..<dates.count {
            let diff = calendar.dateComponents([.day], from: dates[i - 1], to: dates[i])
            #expect(diff.day == 7)
        }
    }

    @Test("Weekly recurrence with same start and end returns one session")
    func weekly_sameStartEnd() {
        let d = date(2026, 6, 1)

        let dates = SessionScheduler.recurringDates(
            from: d, until: d, frequency: .weekly, calendar: calendar
        )

        #expect(dates.count == 1)
        #expect(dates.first == d)
    }

    // MARK: - Biweekly recurrence

    @Test("Biweekly recurrence generates correct number of sessions")
    func biweekly_correctCount() {
        let start = date(2026, 3, 2) // Monday
        let end = date(2026, 4, 27)  // ~8 weeks later

        let dates = SessionScheduler.recurringDates(
            from: start, until: end, frequency: .biweekly, calendar: calendar
        )

        // Mar 2, 16, 30, Apr 13, 27 = 5 sessions
        #expect(dates.count == 5)
    }

    @Test("Biweekly recurrence dates are exactly 14 days apart")
    func biweekly_fourteenDayIntervals() {
        let start = date(2026, 1, 5)
        let end = date(2026, 3, 30)

        let dates = SessionScheduler.recurringDates(
            from: start, until: end, frequency: .biweekly, calendar: calendar
        )

        for i in 1..<dates.count {
            let diff = calendar.dateComponents([.day], from: dates[i - 1], to: dates[i])
            #expect(diff.day == 14)
        }
    }

    // MARK: - Edge cases

    @Test("End date before start date returns empty")
    func endBeforeStart_empty() {
        let start = date(2026, 6, 15)
        let end = date(2026, 6, 1)

        let dates = SessionScheduler.recurringDates(
            from: start, until: end, frequency: .weekly, calendar: calendar
        )

        #expect(dates.isEmpty)
    }

    @Test("Preserves time of day across recurrences")
    func preservesTimeOfDay() {
        let start = date(2026, 3, 2, 14) // 2 PM
        let end = date(2026, 3, 23)

        let dates = SessionScheduler.recurringDates(
            from: start, until: end, frequency: .weekly, calendar: calendar
        )

        for d in dates {
            let hour = calendar.component(.hour, from: d)
            #expect(hour == 14)
        }
    }

    // MARK: - DST handling

    @Test("Weekly recurrence across DST spring-forward produces correct day count")
    func weekly_acrossDST() {
        // US DST spring forward: Mar 8, 2026
        var usCal = Calendar(identifier: .gregorian)
        usCal.timeZone = TimeZone(identifier: "America/New_York")!

        let start = usCal.date(from: DateComponents(year: 2026, month: 3, day: 2, hour: 10))!
        let end = usCal.date(from: DateComponents(year: 2026, month: 3, day: 23, hour: 10))!

        let dates = SessionScheduler.recurringDates(
            from: start, until: end, frequency: .weekly, calendar: usCal
        )

        // Mar 2, 9, 16, 23 = 4 sessions
        #expect(dates.count == 4)

        // Each should be on a Monday
        for d in dates {
            #expect(usCal.component(.weekday, from: d) == 2) // Monday
        }
    }
}
