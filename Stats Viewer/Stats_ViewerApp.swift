import SwiftUI
import SwiftData

@main
struct Stats_ViewerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(StatbelServiceImpl())
        }
        .modelContainer(sharedModelContainer)
    }
}
