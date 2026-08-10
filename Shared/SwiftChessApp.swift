import SwiftUI
import SwiftData

@main
struct SwiftChessApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CollectionEntity.self, GameEntity.self])
    }
}
