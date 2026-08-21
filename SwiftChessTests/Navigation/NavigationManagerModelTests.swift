import Testing
@testable import SwiftChess

@MainActor
struct NavigationManagerModelTests {

    private func makeGame(white: String, black: String) -> GameData {
        GameData(
            headers: ["White": white, "Black": black],
            moves: [],
            result: "*",
            comment: nil
        )
    }

    @Test func testOpenFiles_appendsCollection() async throws {
        let imported = [makeGame(white: "Alice", black: "Bob")]
        let repository = FakeGameCollectionRepository(importResult: imported)
        let testee = NavigationManagerModel(repository: repository)

        let url = URL(fileURLWithPath: "/tmp/opening.pgn")
        await testee.openFiles(urls: [url])

        #expect(testee.collections.count == 1)
        let collection = try #require(testee.collections.first)
        #expect(collection.name == "opening.pgn")
        #expect(collection.games == imported)
        #expect(repository.storedCollections == testee.collections)
    }

    @Test func testSave_roundTrips() throws {
        let repository = FakeGameCollectionRepository()
        let testee = NavigationManagerModel(repository: repository)

        let collection = GameCollection(
            name: "Round trip",
            expanded: true,
            games: [makeGame(white: "Carol", black: "Dave")]
        )
        testee.collections = [collection]
        testee.save()

        #expect(repository.storedCollections == [collection])
    }

    @Test func testDelete_removesCollection() throws {
        let keep = GameCollection(name: "Keep", expanded: true)
        let remove = GameCollection(name: "Remove", expanded: true)
        let repository = FakeGameCollectionRepository(collections: [keep, remove])
        let testee = NavigationManagerModel(repository: repository)

        #expect(testee.collections.count == 2)

        testee.collections.removeAll { $0.id == remove.id }
        testee.save()

        #expect(testee.collections == [keep])
        #expect(repository.storedCollections == [keep])
    }
}
