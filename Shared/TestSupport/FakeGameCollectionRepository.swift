import Foundation

@MainActor
final class FakeGameCollectionRepository: GameCollectionRepository {

    private(set) var storedCollections: [GameCollection]

    init(collections: [GameCollection] = []) {
        self.storedCollections = collections
    }

    func load() throws -> [GameCollection] {
        storedCollections
    }

    func save(_ collections: [GameCollection]) throws {
        storedCollections = collections
    }
}
