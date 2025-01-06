import SwiftUI
import SwiftData
import Logging

@main
struct Stats_ViewerApp: App {
    
    init() {
        LoggingSystem.bootstrap { label in
            print("Setting up logging for \(label)")
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .debug
            return handler
        }
    }
    
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
                .environmentObject(StatbelService())
        }
        .modelContainer(sharedModelContainer)
    }
}
