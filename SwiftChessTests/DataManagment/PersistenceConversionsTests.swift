import Testing
import SwiftUI
import SwiftData
@testable import SwiftChess

struct PersistenceConversionsTests {

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: GameEntity.self, CollectionEntity.self, configurations: config)
        return ModelContext(container)
    }

    @Test func testToGameData_corruptMovesData_throws() throws {
        let context = try makeContext()
        let entity = GameEntity(
            title: "corrupt",
            headersData: try JSONEncoder().encode([String: String]()),
            movesData: Data("this is not valid json".utf8),
            result: "*",
            comment: nil,
            order: 0
        )
        context.insert(entity)

        #expect(throws: (any Error).self) { try entity.toGameData() }
    }

    @Test func testToGameData_validData_roundTrips() throws {
        let context = try makeContext()
        let entity = try GameEntity(from: GameData(headers: ["White": "A"], moves: [], result: "*", comment: nil), order: 0)
        context.insert(entity)

        let gameData = try entity.toGameData()
        #expect(gameData.headers["White"] == "A")
    }
}
