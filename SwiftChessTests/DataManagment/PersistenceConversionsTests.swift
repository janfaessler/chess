import Testing
import SwiftUI
import SwiftData
@testable import SwiftChess
import SwiftChessCore

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

        let highlight = SquareHighlight(color: .green, square: "e4")
        let arrow = BoardArrow(color: .red, from: "e2", to: "e4")
        let variationMove = MoveData(move: "d4", annotation: .good, variations: [], comment: "Queen pawn")
        let e4 = MoveData(
            move: "e4",
            annotation: .brilliant,
            variations: [[variationMove]],
            comment: "King pawn",
            highlights: [highlight],
            arrows: [arrow]
        )
        let original = GameData(headers: ["White": "Alice", "Black": "Bob"], moves: [e4], result: "1-0", comment: "Opening")
        let entity = try GameEntity(from: original, order: 0)
        context.insert(entity)

        let roundTripped = try entity.toGameData()

        #expect(roundTripped.headers["White"] == "Alice")
        #expect(roundTripped.headers["Black"] == "Bob")
        #expect(roundTripped.result == "1-0")
        #expect(roundTripped.comment == "Opening")

        let firstMove = try #require(roundTripped.moves.first)
        #expect(firstMove.move == "e4")
        #expect(firstMove.annotation == .brilliant)
        #expect(firstMove.comment == "King pawn")
        #expect(firstMove.highlights == [highlight])
        #expect(firstMove.arrows == [arrow])

        let firstVariationMove = try #require(firstMove.variations.first?.first)
        #expect(firstVariationMove.move == "d4")
        #expect(firstVariationMove.annotation == .good)
        #expect(firstVariationMove.comment == "Queen pawn")
    }
}
