import SwiftUI
import SwiftData

@main
struct ReflectionsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ReflectionQuestion.self,
            ReflectionSession.self,
            ReflectionAnswer.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 860, minHeight: 620)
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
