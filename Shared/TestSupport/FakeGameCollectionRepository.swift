import Foundation

@MainActor
final class FakeGameCollectionRepository: GameCollectionRepository {

    private(set) var storedCollections: [GameCollection]
    var shouldThrowOnLoad = false
    var shouldThrowOnSave = false

    init(collections: [GameCollection] = []) {
        self.storedCollections = collections
    }

    func load() throws -> [GameCollection] {
        if shouldThrowOnLoad { throw RepositoryError.loadCollectionFailed(FakeRepositoryError.forced) }
        return storedCollections
    }

    func save(_ collections: [GameCollection]) throws {
        if shouldThrowOnSave { throw RepositoryError.persistenceFailed(FakeRepositoryError.forced) }
        storedCollections = collections
    }
}

private enum FakeRepositoryError: Error { case forced }
