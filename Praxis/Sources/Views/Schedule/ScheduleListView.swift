import SwiftUI
import SwiftData

struct ScheduleListView: View {
    @Query(sort: \Session.date) private var allSessions: [Session]

    private var upcomingSessions: [Session] {
        allSessions.filter { $0.status == .upcoming && $0.date > .now }
    }

    private var groupedByDay: [(date: Date, sessions: [Session])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: upcomingSessions) { session in
            calendar.startOfDay(for: session.date)
        }
        return grouped
            .sorted { $0.key < $1.key }
            .map { (date: $0.key, sessions: $0.value) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedByDay, id: \.date) { group in
                    Section {
                        ForEach(group.sessions) { session in
                            NavigationLink(value: session) {
                                ScheduleRowView(session: session)
                            }
                        }
                    } header: {
                        Text(group.date, format: .dateTime.weekday(.wide).month(.wide).day().year())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .textCase(nil)
                    }
                }
            }
            .listStyle(.grouped)
            .headerProminence(.increased)
            .overlay {
                if upcomingSessions.isEmpty {
                    ContentUnavailableView(
                        "No Upcoming Sessions",
                        systemImage: "calendar",
                        description: Text("Schedule sessions from a client's page.")
                    )
                }
            }
            .navigationTitle("Schedule")
            .navigationDestination(for: Session.self) { session in
                SessionDetailView(session: session)
            }
        }
    }
}

struct ScheduleRowView: View {
    let session: Session

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.client?.name ?? "Unknown")
                    .font(.headline)

                Text(session.date, format: .dateTime.hour().minute())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(session.date, format: .relative(presentation: .named))
                .font(.caption)
                .foregroundStyle(.accent)
        }
        .padding(.vertical, 2)
    }
}
