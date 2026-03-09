import SwiftUI
import SwiftData

struct RemindersListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reminder.createdAt, order: .reverse) private var reminders: [Reminder]
    @State private var showingAddReminder = false

    private var pendingReminders: [Reminder] {
        reminders.filter { !$0.isCompleted }
    }

    private var completedReminders: [Reminder] {
        reminders.filter { $0.isCompleted }
    }

    var body: some View {
        NavigationStack {
            List {
                if !pendingReminders.isEmpty {
                    Section("Pending") {
                        ForEach(pendingReminders) { reminder in
                            ReminderRowView(reminder: reminder)
                        }
                        .onDelete { offsets in
                            deleteReminders(from: pendingReminders, at: offsets)
                        }
                    }
                }

                if !completedReminders.isEmpty {
                    Section("Completed") {
                        ForEach(completedReminders) { reminder in
                            ReminderRowView(reminder: reminder)
                        }
                        .onDelete { offsets in
                            deleteReminders(from: completedReminders, at: offsets)
                        }
                    }
                }

                if reminders.isEmpty {
                    ContentUnavailableView(
                        "No Reminders",
                        systemImage: "bell",
                        description: Text("Tap + to create a reminder.")
                    )
                }
            }
            .navigationTitle("Reminders")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddReminder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView()
            }
        }
    }

    private func deleteReminders(from list: [Reminder], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(list[index])
        }
    }
}
