import SwiftUI
import SwiftData

@main
struct SwiftChessApp: App {

    private let container: ModelContainer
    @State private var engineSettings = EngineSettings()

    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
        if TestSupport.isUITesting {
            container = TestSupport.makeSeededContainer()
        } else {
            container = Self.makePersistentContainer()
        }
    }

    private static func makePersistentContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: CollectionEntity.self, GameEntity.self)
        } catch {
            Log.logger("SwiftChessApp").error("Persistent store unavailable, using in-memory fallback: \(error)")
            return makeInMemoryFallback()
        }
    }

    private static func makeInMemoryFallback() -> ModelContainer {
        do {
            return try ModelContainer(
                for: CollectionEntity.self, GameEntity.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            fatalError("Unable to create an in-memory ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
        .environment(engineSettings)
        #if os(macOS)
        Settings {
            SettingsView()
        }
        .environment(engineSettings)
        #endif
    }
}
