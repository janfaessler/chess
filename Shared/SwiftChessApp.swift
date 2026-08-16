import SwiftUI
import SwiftData

@main
struct SwiftChessApp: App {

    private let container: ModelContainer

    init() {
        if TestSupport.isUITesting {
            container = TestSupport.makeSeededContainer()
        } else {
            container = try! ModelContainer(for: CollectionEntity.self, GameEntity.self)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
