import Foundation

@MainActor
protocol FileRepository {
    func importGames(from url: URL) async throws -> [GameData]
}
