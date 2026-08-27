import Testing
@testable import SwiftChessCore

class ChessTestBase {

    var testee: ChessGame?
    var moveLog: [Move] = []
    private var startingPosition: Position = try! PositionFactory.startingPosition()

    init() {
        let pos = try! PositionFactory.startingPosition()
        testee = ChessGame(pos)
        startingPosition = pos
        moveLog = []
    }

    func loadMoves(_ pgn: String) -> [Move] {
        var result: [Move] = []
        var position = try! PositionFactory.startingPosition()
        let pgnMoves = PgnParser.parse(pgn).first?.moves ?? []
        for pgnmove in pgnMoves {
            if let move = MoveFactory.create(pgnmove.move, position: position) {
                result += [move]
                if let newPosition = PositionFactory.getPosition(move, position: position) {
                    position = newPosition
                }
            }
        }
        return result
    }

    func moveAndAssert(
        from: String,
        to: String,
        type: PieceType,
        color: PieceColor,
        moveType: MoveType = .normal,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let testee = try #require(self.testee, sourceLocation: sourceLocation)
        guard let startFigure = Piece.create(from, type: type, color: color),
              let endFigure = Piece.create(to, type: type, color: color, moved: true),
              let move = Move(to, piece: startFigure, type: moveType) else {
            Issue.record("Could not construct move from \(from) to \(to)", sourceLocation: sourceLocation)
            return
        }
        let pieceCount = testee.figures.count
        try testee.move(move)
        #expect(!figureExist(startFigure, testee: testee), "\(color) \(type) should have left \(from)", sourceLocation: sourceLocation)
        #expect(figureExist(endFigure, testee: testee), "\(color) \(type) should be at \(to)", sourceLocation: sourceLocation)
        #expect(testee.figures.count == pieceCount, "piece count changed unexpectedly after non-capture move", sourceLocation: sourceLocation)
    }

    func moveAndAssert(
        notation: String,
        toField: String,
        type: PieceType,
        color: PieceColor,
        moveType: MoveType = .normal,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let testee = try #require(self.testee, sourceLocation: sourceLocation)
        let move = try #require(
            MoveFactory.create(notation, position: testee.position),
            "move \(notation) could not be created",
            sourceLocation: sourceLocation
        )
        let endFigure = Piece.create(toField, type: type, color: color, moved: true)!
        try testee.move(move)
        moveLog.append(move)
        #expect(figureExist(endFigure, testee: testee), "\(color) \(type) should be at \(toField) after \(notation)", sourceLocation: sourceLocation)
    }

    func moveAndAssertError(
        _ from: String,
        to: String,
        type: PieceType,
        color: PieceColor,
        moveType: MoveType = .normal,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let testee = try #require(self.testee, sourceLocation: sourceLocation)
        let startFigure = Piece.create(from, type: type, color: color)!
        let move = Move(to, piece: startFigure, type: moveType)!
        #expect(throws: (any Error).self, sourceLocation: sourceLocation) {
            try testee.move(move)
        }
    }

    func moveAndAssertError(
        _ move: Move,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let testee = try #require(self.testee, sourceLocation: sourceLocation)
        #expect(throws: (any Error).self, sourceLocation: sourceLocation) {
            try testee.move(move)
        }
    }

    func moveAndAssertError(
        _ notation: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let testee = try #require(self.testee, sourceLocation: sourceLocation)
        #expect(throws: (any Error).self, sourceLocation: sourceLocation) {
            try testee.move(notation)
        }
    }

    func captureAndAssert(
        _ from: String,
        to: String,
        type: PieceType,
        color: PieceColor,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let testee = try #require(self.testee, sourceLocation: sourceLocation)
        let startFigure = Piece.create(from, type: type, color: color)!
        let endFigure = Piece.create(to, type: type, color: color)!
        let move = Move(to, piece: startFigure, type: .normal)!
        let pieceCount = testee.figures.count
        try testee.move(move)
        #expect(!figureExist(startFigure, testee: testee), "\(color) \(type) should have left \(from)", sourceLocation: sourceLocation)
        #expect(figureExist(endFigure, testee: testee), "\(color) \(type) should be at \(to)", sourceLocation: sourceLocation)
        #expect(testee.figures.count == pieceCount - 1, "capture should reduce piece count by 1", sourceLocation: sourceLocation)
    }

    func captureAndAssertError(
        _ from: String,
        to: String,
        type: PieceType,
        color: PieceColor,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let testee = try #require(self.testee, sourceLocation: sourceLocation)
        let startFigure = Piece.create(from, type: type, color: color)!
        let move = Move(to, piece: startFigure, type: .normal)!
        #expect(throws: (any Error).self, sourceLocation: sourceLocation) {
            try testee.move(move)
        }
    }

    func captureAndAssertPromotion(
        _ from: String,
        to: String,
        type: PieceType,
        color: PieceColor,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let testee = try #require(self.testee, sourceLocation: sourceLocation)
        let startFigure = Piece.create(from, type: type, color: color)!
        let endFigure = Piece.create(to, type: .queen, color: color)!
        let move = Move(to, piece: startFigure, type: .promotion)!
        let pieceCount = testee.figures.count
        try testee.move(move)
        #expect(!figureExist(startFigure, testee: testee), "\(color) \(type) should have left \(from)", sourceLocation: sourceLocation)
        #expect(figureExist(endFigure, testee: testee), "\(color) queen should be at \(to) after promotion capture", sourceLocation: sourceLocation)
        #expect(testee.figures.count == pieceCount - 1, "promotion-capture should reduce piece count by 1", sourceLocation: sourceLocation)
    }

    func assertPossibleMoves(
        forFigure: any ChessPiece,
        moves: [Move],
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let testee = try #require(self.testee, sourceLocation: sourceLocation)
        let piece = testee.figures.first(where: { $0.equals(forFigure) })!
        let possibleMoves = testee.getPossibleMoves(forPiece: piece)
        #expect(possibleMoves.elementsEqual(moves), sourceLocation: sourceLocation)
    }

    func assertFigureExists(
        _ f: any ChessPiece,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        #expect(figureExist(f, testee: testee), "\(f.info()) does not exist", sourceLocation: sourceLocation)
    }

    func assertFigureNotExists(
        _ f: any ChessPiece,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        #expect(!figureExist(f, testee: testee), "\(f.info()) still exists", sourceLocation: sourceLocation)
    }

    /// Generates SAN notation for each move in the game log by replaying from the starting position.
    func moveLogNotations() -> [String] {
        guard let testee else { return [] }
        var position = startingPosition
        return testee.moveLog.map { move in
            let notation = NotationFactory.generate(move, position: position)
            position = position.applying(move)
            return notation
        }
    }

    func assertMoves(
        _ expectedMoves: [String],
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        try #require(self.testee, sourceLocation: sourceLocation)
        let actual = moveLogNotations()
        #expect(
            actual == expectedMoves,
            "[\(actual.joined(separator: ","))] is not equal [\(expectedMoves.joined(separator: ","))]",
            sourceLocation: sourceLocation
        )
    }

    func assertMoves(
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let testee = try #require(self.testee, sourceLocation: sourceLocation)
        let actual = testee.moveLog
        #expect(
            actual == moveLog,
            "[\(actual.map(\.info).joined(separator: ","))] is not equal [\(moveLog.map(\.info).joined(separator: ","))]",
            sourceLocation: sourceLocation
        )
    }

    func assertGameState(
        _ expectedState: GameState,
        fen: String = "",
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let testee = try #require(self.testee, sourceLocation: sourceLocation)
        let gameState = testee.getGameState()
        #expect(gameState == expectedState, "\(gameState) is not equal to \(expectedState). Fen: \(fen)", sourceLocation: sourceLocation)
    }

    func figureExist(_ figure: any ChessPiece, testee: ChessGame) -> Bool {
        testee.figures.contains(where: { $0.equals(figure) })
    }

    func loadFen(_ fen: String, sourceLocation: SourceLocation = #_sourceLocation) {
        let position = PositionFactory.loadPosition(fen)
        #expect(position != nil, "Invalid FEN: \(fen)", sourceLocation: sourceLocation)
        guard let position else { return }
        startingPosition = position
        moveLog = []
        testee = ChessGame(position)
    }
}
