import Foundation

@MainActor
protocol GameCollectionRepository {
    func load() throws -> [GameCollection]
    func save(_ collections: [GameCollection]) throws
}

extension GameCollectionRepository {
    func load() async throws -> [GameCollection] {
        let syncLoad: () throws -> [GameCollection] = self.load
        return try syncLoad()
    }
}
