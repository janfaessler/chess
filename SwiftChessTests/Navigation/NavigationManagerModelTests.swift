import XCTest
@testable import SwiftChess

final class NavigationManagerModelTests: XCTestCase {

    private func makeGame(white: String, black: String) -> GameData {
        GameData(
            headers: ["White": white, "Black": black],
            moves: [],
            result: "*",
            comment: nil
        )
    }

    func testOpenFiles_appendsCollection() async throws {
        let imported = [makeGame(white: "Alice", black: "Bob")]
        let repository = FakeGameCollectionRepository(importResult: imported)
        let testee = NavigationManagerModel(repository: repository)

        let url = URL(fileURLWithPath: "/tmp/opening.pgn")
        await testee.openFiles(urls: [url])

        XCTAssertEqual(testee.collections.count, 1)
        let collection = try XCTUnwrap(testee.collections.first)
        XCTAssertEqual(collection.name, "opening.pgn")
        XCTAssertEqual(collection.games, imported)
        // The append is persisted through the repository.
        XCTAssertEqual(repository.storedCollections, testee.collections)
    }

    func testSave_roundTrips() throws {
        let repository = FakeGameCollectionRepository()
        let testee = NavigationManagerModel(repository: repository)

        let collection = GameCollection(
            name: "Round trip",
            expanded: true,
            games: [makeGame(white: "Carol", black: "Dave")]
        )
        testee.collections = [collection]
        testee.save()

        XCTAssertEqual(repository.storedCollections, [collection])
    }

    func testDelete_removesCollection() throws {
        let keep = GameCollection(name: "Keep", expanded: true)
        let remove = GameCollection(name: "Remove", expanded: true)
        let repository = FakeGameCollectionRepository(collections: [keep, remove])
        let testee = NavigationManagerModel(repository: repository)

        XCTAssertEqual(testee.collections.count, 2)

        testee.collections.removeAll { $0.id == remove.id }
        testee.save()

        XCTAssertEqual(testee.collections, [keep])
        XCTAssertEqual(repository.storedCollections, [keep])
    }
}
