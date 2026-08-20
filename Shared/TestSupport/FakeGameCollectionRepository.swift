import Foundation


@MainActor
final class FakeGameCollectionRepository: GameCollectionRepository {

    private(set) var storedCollections: [GameCollection]
    var importResult: [GameData]

    init(collections: [GameCollection] = [], importResult: [GameData] = []) {
        self.storedCollections = collections
        self.importResult = importResult
    }

    func load() -> [GameCollection] {
        storedCollections
    }

    func save(_ collections: [GameCollection]) {
        storedCollections = collections
    }

    func importGames(from url: URL) async -> [GameData] {
        importResult
    }
}
