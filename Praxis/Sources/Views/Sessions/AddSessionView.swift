import SwiftUI
import SwiftData

struct AddSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let client: Client

    @State private var date = Date()
    @State private var templateType: NoteTemplate?
    @State private var isRecurring = false
    @State private var recurrenceFrequency: RecurrenceFrequency = .weekly
    @State private var recurrenceEndDate = Calendar.current.date(byAdding: .month, value: 3, to: .now)!

    var body: some View {
        NavigationStack {
            Form {
                Section("Session") {
                    DatePicker("Date & Time", selection: $date)
                }

                Section("Notes Template") {
                    Picker("Template", selection: $templateType) {
                        Text("None").tag(nil as NoteTemplate?)
                        ForEach(NoteTemplate.allCases) { template in
                            Text(template.displayName).tag(template as NoteTemplate?)
                        }
                    }
                }

                Section("Recurring") {
                    Toggle("Repeat", isOn: $isRecurring)

                    if isRecurring {
                        Picker("Frequency", selection: $recurrenceFrequency) {
                            ForEach(RecurrenceFrequency.allCases) { freq in
                                Text(freq.displayName).tag(freq)
                            }
                        }

                        DatePicker("Until", selection: $recurrenceEndDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        let noteContent = templateType?.templateContent

        if isRecurring {
            let dates = SessionScheduler.recurringDates(
                from: date,
                until: recurrenceEndDate,
                frequency: recurrenceFrequency
            )
            for sessionDate in dates {
                let session = Session(
                    client: client,
                    date: sessionDate,
                    noteContent: noteContent,
                    templateType: templateType
                )
                modelContext.insert(session)
            }
        } else {
            let session = Session(
                client: client,
                date: date,
                noteContent: noteContent,
                templateType: templateType
            )
            modelContext.insert(session)
        }

        try? modelContext.save()
        dismiss()
    }
}
