import SwiftUI

struct EditClientView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var client: Client

    @State private var name: String
    @State private var age: String
    @State private var gender: Gender?
    @State private var phone: String
    @State private var email: String
    @State private var notes: String

    init(client: Client) {
        self.client = client
        _name = State(initialValue: client.name)
        _age = State(initialValue: client.age.map(String.init) ?? "")
        _gender = State(initialValue: client.gender)
        _phone = State(initialValue: client.phone ?? "")
        _email = State(initialValue: client.email ?? "")
        _notes = State(initialValue: client.notes ?? "")
    }

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
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Client")
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
        client.name = name.trimmingCharacters(in: .whitespaces)
        client.age = Int(age)
        client.gender = gender
        client.phone = phone.isEmpty ? nil : phone
        client.email = email.isEmpty ? nil : email
        client.notes = notes.isEmpty ? nil : notes
        dismiss()
    }
}
