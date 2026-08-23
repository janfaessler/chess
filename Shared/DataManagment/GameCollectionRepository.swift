import Foundation

@MainActor
protocol GameCollectionRepository {
    func load() throws -> [GameCollection]
    func save(_ collections: [GameCollection]) throws
}
