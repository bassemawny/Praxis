import Testing
import Foundation
@testable import Praxis

@Suite("Notification Lead Time Tests")
struct NotificationLeadTimeTests {

    @Test("oneHour timeInterval is 3600 seconds")
    func oneHour() {
        #expect(NotificationLeadTime.oneHour.timeInterval == 3600)
    }

    @Test("sixHours timeInterval is 21600 seconds")
    func sixHours() {
        #expect(NotificationLeadTime.sixHours.timeInterval == 21600)
    }

    @Test("twelveHours timeInterval is 43200 seconds")
    func twelveHours() {
        #expect(NotificationLeadTime.twelveHours.timeInterval == 43200)
    }

    @Test("twentyFourHours timeInterval is 86400 seconds")
    func twentyFourHours() {
        #expect(NotificationLeadTime.twentyFourHours.timeInterval == 86400)
    }

    @Test("Lead time intervals are in ascending order")
    func ascendingOrder() {
        let intervals = NotificationLeadTime.allCases.map(\.timeInterval)
        #expect(intervals == intervals.sorted())
    }
}

@Suite("Notification Trigger Date Calculation Tests")
struct NotificationTriggerDateTests {

    /// Mirrors the trigger date logic from NotificationService.scheduleNotification
    private func triggerDate(dueDate: Date, leadTime: NotificationLeadTime) -> Date {
        dueDate.addingTimeInterval(-leadTime.timeInterval)
    }

    @Test("Trigger date is correctly offset from due date for each lead time")
    func triggerDateOffsets() {
        let dueDate = Date.now.addingTimeInterval(86400 * 2) // 2 days from now

        for leadTime in NotificationLeadTime.allCases {
            let trigger = triggerDate(dueDate: dueDate, leadTime: leadTime)
            let diff = dueDate.timeIntervalSince(trigger)
            #expect(diff == leadTime.timeInterval)
        }
    }

    @Test("Trigger date in the past means notification should not be scheduled")
    func pastTriggerDate() {
        // Due date is 30 minutes from now, lead time is 1 hour
        let dueDate = Date.now.addingTimeInterval(1800)
        let trigger = triggerDate(dueDate: dueDate, leadTime: .oneHour)

        // Trigger would be 30 minutes ago — should not schedule
        #expect(trigger < .now)
    }

    @Test("Trigger date in the future means notification should be scheduled")
    func futureTriggerDate() {
        let dueDate = Date.now.addingTimeInterval(86400) // tomorrow
        let trigger = triggerDate(dueDate: dueDate, leadTime: .oneHour)

        #expect(trigger > .now)
    }

    @Test("24-hour lead time with due date exactly 24 hours away triggers at now")
    func exactBoundary() {
        let dueDate = Date.now.addingTimeInterval(86400)
        let trigger = triggerDate(dueDate: dueDate, leadTime: .twentyFourHours)

        // Should be approximately now (within a second)
        #expect(abs(trigger.timeIntervalSinceNow) < 1)
    }
}
