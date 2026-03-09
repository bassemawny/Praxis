import SwiftUI
import SwiftData

struct ClientsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Client.name) private var clients: [Client]
    @State private var filter: ClientFilter = .active
    @State private var searchText = ""
    @State private var showingAddClient = false

    private var filteredClients: [Client] {
        let byArchive = clients.filter { client in
            switch filter {
            case .active: return !client.isArchived
            case .archived: return client.isArchived
            }
        }

        guard !searchText.isEmpty else { return byArchive }

        return byArchive.filter { client in
            client.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Filter", selection: $filter) {
                    ForEach(ClientFilter.allCases) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                List {
                    ForEach(filteredClients) { client in
                        NavigationLink(value: client) {
                            ClientRowView(client: client)
                        }
                    }
                }
            }
            .navigationTitle("Clients")
            .navigationDestination(for: Client.self) { client in
                ClientDetailView(client: client)
            }
            .searchable(text: $searchText, prompt: "Search clients")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddClient = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddClientView()
            }
            .overlay {
                if filteredClients.isEmpty {
                    ContentUnavailableView {
                        Label(
                            filter == .active ? "No Clients" : "No Archived Clients",
                            systemImage: "person.2"
                        )
                    } description: {
                        if filter == .active {
                            Text("Tap + to add your first client.")
                        }
                    }
                }
            }
        }
    }
}

enum ClientFilter: String, CaseIterable, Identifiable {
    case active
    case archived

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .active: return String(localized: "Active")
        case .archived: return String(localized: "Archived")
        }
    }
}
