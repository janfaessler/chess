import Testing
import SwiftUI
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

    private func makeSut(collections: [GameCollection] = [], importResult: [GameData] = []) -> (NavigationManagerModel, FakeGameCollectionRepository, FakeFileRepository) {
        let gameDataRepo = FakeGameCollectionRepository(collections: collections)
        let fileRepo = FakeFileRepository(importResult: importResult)
        let sut = NavigationManagerModel(gameDataRepo: gameDataRepo, fileRepo: fileRepo)
        return (sut, gameDataRepo, fileRepo)
    }

    @Test func testOpenFiles_appendsCollection() async throws {
        let imported = [makeGame(white: "Alice", black: "Bob")]
        let (testee, gameDataRepo, _) = makeSut(importResult: imported)

        let url = URL(fileURLWithPath: "/tmp/opening.pgn")
        await testee.openFiles(urls: [url])

        #expect(testee.collections.count == 1)
        let collection = try #require(testee.collections.first)
        #expect(collection.name == "opening.pgn")
        #expect(collection.games == imported)
        #expect(gameDataRepo.storedCollections == testee.collections)
    }

    @Test func testSave_roundTrips() throws {
        let (testee, gameDataRepo, _) = makeSut()

        let collection = GameCollection(
            name: "Round trip",
            expanded: true,
            games: [makeGame(white: "Carol", black: "Dave")]
        )
        testee.collections = [collection]
        testee.save()

        #expect(gameDataRepo.storedCollections == [collection])
    }

    @Test func testDelete_removesCollection() throws {
        let keep = GameCollection(name: "Keep", expanded: true)
        let remove = GameCollection(name: "Remove", expanded: true)
        let (testee, gameDataRepo, _) = makeSut(collections: [keep, remove])

        #expect(testee.collections.count == 2)

        testee.collections.removeAll { $0.id == remove.id }
        testee.save()

        #expect(testee.collections == [keep])
        #expect(gameDataRepo.storedCollections == [keep])
    }

    @Test func testAddGame_appendsToCollection() throws {
        let collection = GameCollection(name: "My Games", expanded: true)
        let (testee, gameDataRepo, _) = makeSut(collections: [collection])

        let game = makeGame(white: "Alice", black: "Bob")
        let added = testee.addGame(game, to: collection)

        #expect(added == game)
        #expect(testee.collections.first?.games == [game])
        #expect(gameDataRepo.storedCollections.first?.games == [game])
    }

    @Test func testAddGame_unknownCollection_returnsNil() throws {
        let (testee, _, _) = makeSut()

        let unknown = GameCollection(name: "Ghost", expanded: true)
        let result = testee.addGame(makeGame(white: "X", black: "Y"), to: unknown)

        #expect(result == nil)
        #expect(testee.collections.isEmpty)
    }

    @Test func testRemoveGame_removesFromCollection() throws {
        let game = makeGame(white: "Alice", black: "Bob")
        let collection = GameCollection(name: "My Games", expanded: true, games: [game])
        let (testee, gameDataRepo, _) = makeSut(collections: [collection])

        testee.removeGame(game)

        #expect(testee.collections.first?.games.isEmpty == true)
        #expect(gameDataRepo.storedCollections.first?.games.isEmpty == true)
    }

    @Test func testUpdateCollection_updatesNameAndPersists() throws {
        let collection = GameCollection(name: "Old Name", expanded: true)
        let (testee, gameDataRepo, _) = makeSut(collections: [collection])

        var updated = collection
        updated.name = "New Name"
        testee.updateCollection(updated)

        #expect(testee.collections.first?.name == "New Name")
        #expect(gameDataRepo.storedCollections.first?.name == "New Name")
    }

    @Test func testRemoveCollection_removesAndPersists() throws {
        let keep = GameCollection(name: "Keep", expanded: true)
        let remove = GameCollection(name: "Remove", expanded: true)
        let (testee, gameDataRepo, _) = makeSut(collections: [keep, remove])

        testee.removeCollection(remove)

        #expect(testee.collections == [keep])
        #expect(gameDataRepo.storedCollections == [keep])
    }

    @Test func testInit_loadFailure_setsLoadFailedError() {
        let repo = FakeGameCollectionRepository()
        repo.shouldThrowOnLoad = true
        let testee = NavigationManagerModel(gameDataRepo: repo, fileRepo: FakeFileRepository())

        guard case .loadFailed = testee.appError else {
            Issue.record("Expected loadFailed error, got \(String(describing: testee.appError))")
            return
        }
    }

    @Test func testSave_failure_setsSaveFailedError() {
        let (testee, repo, _) = makeSut()
        repo.shouldThrowOnSave = true

        testee.save()

        guard case .saveFailed = testee.appError else {
            Issue.record("Expected saveFailed error, got \(String(describing: testee.appError))")
            return
        }
    }

    @Test func testDismissError_clearsError() {
        let (testee, repo, _) = makeSut()
        repo.shouldThrowOnSave = true
        testee.save()

        testee.dismissError()

        #expect(testee.appError == nil)
    }

    @Test func testRetry_afterSaveFailure_retriesSave() {
        let (testee, repo, _) = makeSut()
        repo.shouldThrowOnSave = true
        testee.save()

        repo.shouldThrowOnSave = false
        testee.retry()

        #expect(testee.appError == nil)
        #expect(repo.storedCollections == testee.collections)
    }

    @Test func testRetry_afterLoadFailure_reloadsCollections() throws {
        let collection = GameCollection(name: "Saved", expanded: true)
        let repo = FakeGameCollectionRepository(collections: [collection])
        repo.shouldThrowOnLoad = true
        let testee = NavigationManagerModel(gameDataRepo: repo, fileRepo: FakeFileRepository())

        repo.shouldThrowOnLoad = false
        testee.retry()

        #expect(testee.appError == nil)
        #expect(testee.collections == [collection])
    }
}
