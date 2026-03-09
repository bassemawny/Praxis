import SwiftUI
import SwiftData

struct AddClientView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var age = ""
    @State private var gender: Gender?
    @State private var phone = ""
    @State private var email = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $name)

                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)

                    Picker("Gender", selection: $gender) {
                        Text("Not specified").tag(nil as Gender?)
                        ForEach(Gender.allCases) { g in
                            Text(g.displayName).tag(g as Gender?)
                        }
                    }
                }

                Section("Contact") {
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section("Notes") {
                    TextField("Initial notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let client = Client(
            name: name.trimmingCharacters(in: .whitespaces),
            age: Int(age),
            gender: gender,
            phone: phone.isEmpty ? nil : phone,
            email: email.isEmpty ? nil : email,
            notes: notes.isEmpty ? nil : notes
        )
        modelContext.insert(client)
        try? modelContext.save()
        dismiss()
    }
}
