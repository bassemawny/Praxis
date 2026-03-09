import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            SplitContentView()
        } else {
            TabContentView()
        }
    }
}

// MARK: - iPhone Tab View

struct TabContentView: View {
    var body: some View {
        TabView {
            ClientsListView()
                .tabItem {
                    Label("Clients", systemImage: "person.2")
                }

            ScheduleListView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }

            RemindersListView()
                .tabItem {
                    Label("Reminders", systemImage: "bell")
                }
        }
    }
}

// MARK: - iPad Split View

struct SplitContentView: View {
    @State private var selectedTab: SidebarTab? = .clients

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(SidebarTab.allCases) { tab in
                    Label(tab.title, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .navigationTitle("Praxis")
        } detail: {
            switch selectedTab {
            case .clients:
                ClientsListView()
            case .schedule:
                ScheduleListView()
            case .reminders:
                RemindersListView()
            case nil:
                ContentUnavailableView("Select a section", systemImage: "sidebar.left")
            }
        }
    }
}

enum SidebarTab: String, CaseIterable, Identifiable {
    case clients
    case schedule
    case reminders

    var id: String { rawValue }

    var title: String {
        switch self {
        case .clients: return String(localized: "Clients")
        case .schedule: return String(localized: "Schedule")
        case .reminders: return String(localized: "Reminders")
        }
    }

    var icon: String {
        switch self {
        case .clients: return "person.2"
        case .schedule: return "calendar"
        case .reminders: return "bell"
        }
    }
}
