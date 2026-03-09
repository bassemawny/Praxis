import Testing
import Foundation
import SwiftData
@testable import Praxis

@Suite("Client Model Tests")
@MainActor
struct ClientModelTests {

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([Client.self, Session.self, Reminder.self, Attachment.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    private func makeClient(in context: ModelContext) -> Client {
        let client = Client(name: "Test Client")
        context.insert(client)
        return client
    }

    private func addSession(
        to client: Client,
        date: Date,
        status: SessionStatus = .upcoming,
        in context: ModelContext
    ) -> Session {
        let session = Session(client: client, date: date, status: status)
        context.insert(session)
        return session
    }

    // MARK: - upcomingSessions

    @Test("upcomingSessions returns only upcoming sessions with future dates, sorted ascending")
    func upcomingSessions_filtersAndSorts() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let client = makeClient(in: context)
        let tomorrow = Date.now.addingTimeInterval(86400)
        let nextWeek = Date.now.addingTimeInterval(86400 * 7)
        let yesterday = Date.now.addingTimeInterval(-86400)

        _ = addSession(to: client, date: nextWeek, status: .upcoming, in: context)
        _ = addSession(to: client, date: tomorrow, status: .upcoming, in: context)
        _ = addSession(to: client, date: yesterday, status: .upcoming, in: context) // past date
        _ = addSession(to: client, date: tomorrow.addingTimeInterval(3600), status: .completed, in: context) // wrong status

        try context.save()

        let upcoming = client.upcomingSessions
        #expect(upcoming.count == 2)
        #expect(upcoming[0].date < upcoming[1].date) // sorted ascending
    }

    @Test("upcomingSessions excludes cancelled sessions")
    func upcomingSessions_excludesCancelled() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let client = makeClient(in: context)
        let tomorrow = Date.now.addingTimeInterval(86400)

        _ = addSession(to: client, date: tomorrow, status: .cancelled, in: context)
        _ = addSession(to: client, date: tomorrow, status: .upcoming, in: context)

        try context.save()

        #expect(client.upcomingSessions.count == 1)
        #expect(client.upcomingSessions.first?.status == .upcoming)
    }

    // MARK: - pastSessions

    @Test("pastSessions returns completed/cancelled/noShow and past-date upcoming sessions, sorted descending")
    func pastSessions_filtersAndSorts() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let client = makeClient(in: context)
        let yesterday = Date.now.addingTimeInterval(-86400)
        let lastWeek = Date.now.addingTimeInterval(-86400 * 7)
        let tomorrow = Date.now.addingTimeInterval(86400)

        _ = addSession(to: client, date: yesterday, status: .completed, in: context)
        _ = addSession(to: client, date: lastWeek, status: .cancelled, in: context)
        _ = addSession(to: client, date: yesterday, status: .upcoming, in: context) // past-date upcoming
        _ = addSession(to: client, date: tomorrow, status: .upcoming, in: context) // future upcoming — excluded

        try context.save()

        let past = client.pastSessions
        #expect(past.count == 3)
        // sorted descending by date
        #expect(past[0].date >= past[1].date)
        #expect(past[1].date >= past[2].date)
    }

    @Test("pastSessions includes noShow sessions")
    func pastSessions_includesNoShow() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let client = makeClient(in: context)
        let yesterday = Date.now.addingTimeInterval(-86400)

        _ = addSession(to: client, date: yesterday, status: .noShow, in: context)

        try context.save()

        #expect(client.pastSessions.count == 1)
        #expect(client.pastSessions.first?.status == .noShow)
    }

    // MARK: - activeSessions

    @Test("activeSessions excludes cancelled, sorted descending")
    func activeSessions_excludesCancelled() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let client = makeClient(in: context)
        let now = Date.now

        _ = addSession(to: client, date: now, status: .upcoming, in: context)
        _ = addSession(to: client, date: now.addingTimeInterval(-3600), status: .completed, in: context)
        _ = addSession(to: client, date: now.addingTimeInterval(-7200), status: .cancelled, in: context)
        _ = addSession(to: client, date: now.addingTimeInterval(-10800), status: .noShow, in: context)

        try context.save()

        let active = client.activeSessions
        #expect(active.count == 3) // excludes cancelled
        #expect(active.contains(where: { $0.status == .cancelled }) == false)
        // sorted descending
        #expect(active[0].date >= active[1].date)
    }

    // MARK: - Edge cases

    @Test("All computed properties return empty for client with no sessions")
    func emptySessions() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let client = makeClient(in: context)
        try context.save()

        #expect(client.upcomingSessions.isEmpty)
        #expect(client.pastSessions.isEmpty)
        #expect(client.activeSessions.isEmpty)
    }
}
