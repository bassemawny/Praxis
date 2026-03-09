import SwiftUI
import SwiftData

@main
struct PraxisApp: App {
    @State private var isUnlocked = false
    @Environment(\.scenePhase) private var scenePhase

    private let authService = AuthenticationService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Client.self,
            Session.self,
            Reminder.self,
            Attachment.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            #if DEBUG
            // Schema likely changed between builds — wipe the local store and start fresh.
            if let storeURL = FileManager.default
                .urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let candidates = ["default.store", "default.store-shm", "default.store-wal"]
                for name in candidates {
                    try? FileManager.default.removeItem(at: storeURL.appending(path: name))
                }
            }
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer after store reset: \(error)")
            }
            #else
            fatalError("Could not create ModelContainer: \(error)")
            #endif
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if isUnlocked {
                    ContentView()
                } else {
                    LockScreenView {
                        authenticate()
                    }
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background {
                    isUnlocked = false
                }
            }
            .onAppear {
                NotificationService.shared.requestPermission()
                authenticate()
            }
        }
        .modelContainer(sharedModelContainer)
    }

    private func authenticate() {
        authService.authenticate { success in
            isUnlocked = success
        }
    }
}
