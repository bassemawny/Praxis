import SwiftUI
import SwiftData

struct ClientDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var client: Client
    @State private var showingNewSession = false
    @State private var showingEditClient = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            Section("Info") {
                if let age = client.age {
                    LabeledContent("Age", value: "\(age)")
                }
                if let gender = client.gender {
                    LabeledContent("Gender", value: gender.displayName)
                }
                if let phone = client.phone {
                    LabeledContent("Phone", value: phone)
                }
                if let email = client.email {
                    LabeledContent("Email", value: email)
                }
            }

            if !client.upcomingSessions.isEmpty {
                Section("Upcoming") {
                    ForEach(client.upcomingSessions) { session in
                        NavigationLink(value: session) {
                            SessionRowView(session: session)
                        }
                    }
                    .onDelete(perform: deleteUpcomingSessions)
                }
            }

            Section("Past Sessions") {
                if client.pastSessions.isEmpty {
                    Text("No sessions yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(client.pastSessions) { session in
                        NavigationLink(value: session) {
                            SessionRowView(session: session)
                        }
                    }
                    .onDelete(perform: deletePastSessions)
                }
            }
        }
        .navigationTitle(client.name)
        .navigationDestination(for: Session.self) { session in
            SessionDetailView(session: session)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingNewSession = true
                    } label: {
                        Label("New Session", systemImage: "plus")
                    }

                    Button {
                        showingEditClient = true
                    } label: {
                        Label("Edit Client", systemImage: "pencil")
                    }

                    Divider()

                    Button {
                        client.isArchived.toggle()
                    } label: {
                        Label(
                            client.isArchived ? "Unarchive" : "Archive",
                            systemImage: client.isArchived ? "tray.and.arrow.up" : "archivebox"
                        )
                    }

                    Divider()

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Client", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingNewSession) {
            AddSessionView(client: client)
        }
        .sheet(isPresented: $showingEditClient) {
            EditClientView(client: client)
        }
        .alert("Delete Client", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                modelContext.delete(client)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete \(client.name) and all their sessions, notes, and attachments.")
        }
    }

    private func deleteUpcomingSessions(at offsets: IndexSet) {
        let sessions = client.upcomingSessions
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }

    private func deletePastSessions(at offsets: IndexSet) {
        let sessions = client.pastSessions
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }
}
