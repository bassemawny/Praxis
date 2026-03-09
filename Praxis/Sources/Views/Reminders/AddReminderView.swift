import SwiftUI
import SwiftData

struct AddReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var client: Client?
    var session: Session?

    @State private var title = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var notificationLeadTime: NotificationLeadTime?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Reminder", text: $title)
                }

                Section {
                    Toggle("Due Date", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker("Date & Time", selection: $dueDate)

                        Picker("Notify", selection: $notificationLeadTime) {
                            Text("No notification").tag(nil as NotificationLeadTime?)
                            ForEach(NotificationLeadTime.allCases) { leadTime in
                                Text(leadTime.displayName).tag(leadTime as NotificationLeadTime?)
                            }
                        }
                    }
                }

                if let client {
                    Section {
                        LabeledContent("Client", value: client.name)
                    }
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let reminder = Reminder(
            title: title.trimmingCharacters(in: .whitespaces),
            dueDate: hasDueDate ? dueDate : nil,
            notificationLeadTime: hasDueDate ? notificationLeadTime : nil,
            client: client,
            session: session
        )
        modelContext.insert(reminder)

        if hasDueDate, let leadTime = notificationLeadTime {
            NotificationService.shared.scheduleNotification(for: reminder, leadTime: leadTime)
        }

        try? modelContext.save()
        dismiss()
    }
}
