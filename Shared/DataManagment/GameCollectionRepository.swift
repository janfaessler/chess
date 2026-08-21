import Foundation

@MainActor
protocol GameCollectionRepository {
    func load() -> [GameCollection]
    func save(_ collections: [GameCollection])
    func importGames(from url: URL) async -> [GameData]
}
