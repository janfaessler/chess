import Foundation

/// Abstraction over game-collection persistence and PGN import.
///
/// Keeps the concrete storage technology (SwiftData) out of
/// `NavigationManagerModel`, so the coordinator depends only on this seam.
@MainActor
protocol GameCollectionRepository {
    func load() -> [GameCollection]
    func save(_ collections: [GameCollection])
    func importGames(from url: URL) async -> [GameData]
}
