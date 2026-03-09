import SwiftUI

struct ReminderRowView: View {
    @Bindable var reminder: Reminder

    var body: some View {
        HStack(spacing: 12) {
            Button {
                reminder.isCompleted.toggle()
            } label: {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(reminder.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .strikethrough(reminder.isCompleted)
                    .foregroundStyle(reminder.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    if let dueDate = reminder.dueDate {
                        Text(dueDate, format: .dateTime.month().day().hour().minute())
                            .font(.caption)
                            .foregroundStyle(dueDate < .now && !reminder.isCompleted ? .red : .secondary)
                    }

                    if let client = reminder.client {
                        Text(client.name)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(.accent.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}
