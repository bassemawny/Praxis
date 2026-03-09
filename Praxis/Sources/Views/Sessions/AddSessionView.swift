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
            let calendar = Calendar.current
            let weekInterval = recurrenceFrequency == .weekly ? 1 : 2
            var currentDate = date

            while currentDate <= recurrenceEndDate {
                let session = Session(
                    client: client,
                    date: currentDate,
                    noteContent: noteContent,
                    templateType: templateType
                )
                modelContext.insert(session)
                guard let next = calendar.date(byAdding: .weekOfYear, value: weekInterval, to: currentDate) else { break }
                currentDate = next
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
