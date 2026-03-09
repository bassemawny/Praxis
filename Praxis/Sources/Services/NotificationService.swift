import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, error in
            if let error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func scheduleNotification(for reminder: Reminder, leadTime: NotificationLeadTime) {
        guard let dueDate = reminder.dueDate else { return }

        let triggerDate = dueDate.addingTimeInterval(-leadTime.timeInterval)
        guard triggerDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = "Praxis Reminder"
        content.body = reminder.title
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let identifier = UUID().uuidString
        reminder.notificationIdentifier = identifier

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
