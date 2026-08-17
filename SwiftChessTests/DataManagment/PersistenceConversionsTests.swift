import XCTest
import SwiftData
@testable import SwiftChess

final class PersistenceConversionsTests: XCTestCase {

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: GameEntity.self, CollectionEntity.self, configurations: config)
        return ModelContext(container)
    }

    func testToGameData_corruptMovesData_returnsNil() throws {
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

        XCTAssertNil(entity.toGameData(), "a game with undecodable moves must decode to nil, not empty data")
    }

    func testToGameData_validData_roundTrips() throws {
        let context = try makeContext()
        let entity = try XCTUnwrap(GameEntity(from: GameData(headers: ["White": "A"], moves: [], result: "*", comment: nil), order: 0))
        context.insert(entity)

        let gameData = try XCTUnwrap(entity.toGameData())
        XCTAssertEqual(gameData.headers["White"], "A")
    }
}
