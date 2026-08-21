import Testing
@testable import SwiftChessCore

class ChessTestBase {

    var testee: ChessGame?
    var moveLog: [String] = []

    init() {
        testee = ChessGame(PositionFactory.startingPosition())
        moveLog = []
    }

    func loadMoves(_ pgn: String) -> [Move] {
        var result: [Move] = []
        var position = PositionFactory.startingPosition()
        let game = PgnMovesParser.parse(pgn)
        for pgnmove in game {
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
        moveType: MoveType = .Normal,
        message: (String, String, any ChessFigure) -> String = { "\($2.color) \($2.type) could not move from \($0) to \($1)" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        let pieceCount = testee.figures.count
        let startFigure = Figure.create(from, type: type, color: color)!
        let endFigure = Figure.create(to, type: type, color: color, moved: true)!
        let move = Move(to, piece: startFigure, type: moveType)!
        var moveError = false
        do { try testee.move(move) } catch { moveError = true }
        let startFigureExists = figureExist(startFigure, testee: testee)
        let endFigureExists = figureExist(endFigure, testee: testee)
        let nextColorToMoveDidNotChange = testee.colorToMove == color

        guard moveError == true || startFigureExists == true || endFigureExists == false || testee.figures.count != pieceCount && nextColorToMoveDidNotChange else {
            return
        }
        Issue.record("\(message(from, to, startFigure))", sourceLocation: sourceLocation)
    }

    func moveAndAssert(
        notation: String,
        toField: String,
        type: PieceType,
        color: PieceColor,
        moveType: MoveType = .Normal,
        message: (String, String, any ChessFigure) -> String = { "\($0): \($2.color) \($2.type) could not move to \($1)" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        let pieceCount = testee.figures.count
        let cache = testee.position
        guard let move = MoveFactory.create(notation, position: cache) else {
            Issue.record("move \(notation) could not be created", sourceLocation: sourceLocation)
            return
        }
        let endFigure = Figure.create(toField, type: type, color: color, moved: true)!
        var moveError = false
        do {
            try testee.move(move)
            moveLog += [notation]
        } catch { moveError = true }
        let endFigureExists = figureExist(endFigure, testee: testee)
        let nextColorToMoveDidNotChange = testee.colorToMove == color

        guard moveError == true,
              endFigureExists == false,
              testee.figures.count != pieceCount && nextColorToMoveDidNotChange else {
            return
        }
        Issue.record("\(message(notation, toField, endFigure))", sourceLocation: sourceLocation)
    }

    func moveAndAssertError(
        _ from: String,
        to: String,
        type: PieceType,
        color: PieceColor,
        moveType: MoveType = .Normal,
        message: (String, String, any ChessFigure) -> String = { "move from \($0) to \($1) of \($2.color) \($2.type) should not be possible" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        let startFigure = Figure.create(from, type: type, color: color)!
        let move = Move(to, piece: startFigure, type: moveType)!
        do { try testee.move(move) } catch { return }
        Issue.record("\(message(from, to, startFigure))", sourceLocation: sourceLocation)
    }

    func moveAndAssertError(
        _ move: Move,
        message: (Move, any ChessFigure) -> String = { "move from \($0.piece.fieldInfo) to \($0.field) of \($1.color) \($1.type) should not be possible" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        do { try testee.move(move) } catch { return }
        Issue.record("\(message(move, move.piece))", sourceLocation: sourceLocation)
    }

    func moveAndAssertError(
        _ notation: String,
        message: (String) -> String = { "move \($0) should not be possible" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        do { try testee.move(notation) } catch { return }
        Issue.record("\(message(notation))", sourceLocation: sourceLocation)
    }

    func captureAndAssert(
        _ from: String,
        to: String,
        type: PieceType,
        color: PieceColor,
        message: (String, String, any ChessFigure) -> String = { "\($2.color) \($2.type) on \($0) could not capture on \($1)" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        let pieceCount = testee.figures.count - 1
        let startFigure = Figure.create(from, type: type, color: color)!
        let endFigure = Figure.create(to, type: type, color: color)!
        let move = Move(to, piece: startFigure, type: .Normal)!
        let nextColorToMoveDidNotChange = testee.colorToMove == color
        var moveError = false
        do { try testee.move(move) } catch { moveError = true }

        guard moveError == true || figureExist(startFigure, testee: testee) == true || figureExist(endFigure, testee: testee) == false || testee.figures.count != pieceCount && nextColorToMoveDidNotChange else {
            return
        }
        Issue.record("\(message(from, to, startFigure))", sourceLocation: sourceLocation)
    }

    func captureAndAssertError(
        _ from: String,
        to: String,
        type: PieceType,
        color: PieceColor,
        message: (String, String, any ChessFigure) -> String = { "\($2.color) \($2.type) on \($0) could not capture on \($1)" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        let startFigure = Figure.create(from, type: type, color: color)!
        let move = Move(to, piece: startFigure, type: .Normal)!
        do { try testee.move(move) } catch { return }
        Issue.record("\(message(from, to, startFigure))", sourceLocation: sourceLocation)
    }

    func captureAndAssertPromotion(
        _ from: String,
        to: String,
        type: PieceType,
        color: PieceColor,
        message: (String, String, any ChessFigure) -> String = { "\($2.color) \($2.type) on \($0) could not capture on \($1)" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        let pieceCount = testee.figures.count - 1
        let startFigure = Figure.create(from, type: type, color: color)!
        let endFigure = Figure.create(to, type: .queen, color: color)!
        let move = Move(to, piece: startFigure, type: .Promotion)!
        let nextColorToMoveDidNotChange = testee.colorToMove == color
        var moveError = false
        do { try testee.move(move) } catch { moveError = true }

        guard moveError == true,
              figureExist(startFigure, testee: testee) == true,
              figureExist(endFigure, testee: testee) == false,
              testee.figures.count != pieceCount && nextColorToMoveDidNotChange else {
            return
        }
        Issue.record("\(message(from, to, startFigure))", sourceLocation: sourceLocation)
    }

    func assertPossibleMoves(
        forFigure: any ChessFigure,
        moves: [Move],
        message: () -> String = { "moves are not equal" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        let piece = testee.figures.first(where: { $0.equals(forFigure) })!
        let possibleMoves = testee.getPossibleMoves(forPiece: piece)
        guard possibleMoves.elementsEqual(moves) == false else { return }
        Issue.record(sourceLocation: sourceLocation)
    }

    func assertFigureExists(
        _ f: any ChessFigure,
        message: (any ChessFigure) -> String = { "\($0.info()) does not exist" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        guard figureExist(f, testee: testee) == false else { return }
        Issue.record("\(message(f))", sourceLocation: sourceLocation)
    }

    func assertFigureNotExists(
        _ f: any ChessFigure,
        message: (any ChessFigure) -> String = { "\($0.info()) still exists" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        guard figureExist(f, testee: testee) == true else { return }
        Issue.record("\(message(f))", sourceLocation: sourceLocation)
    }

    func assertMoves(
        _ expectedMoves: [String],
        message: ([String], [String]) -> String = { "[\($0.joined(separator: ","))] is not equal [\($1.joined(separator: ","))]" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        let moves = testee.moveLog
        guard !moves.elementsEqual(expectedMoves) else { return }
        Issue.record("\(message(moves, expectedMoves))", sourceLocation: sourceLocation)
    }

    func assertMoves(
        message: ([String], [String]) -> String = { "[\($0.joined(separator: ","))] is not equal [\($1.joined(separator: ","))]" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        let moves = testee.moveLog
        guard !moves.elementsEqual(moveLog) else { return }
        Issue.record("\(message(moves, moveLog))", sourceLocation: sourceLocation)
    }

    func assertGameState(
        _ expectedState: GameState,
        fen: String = "",
        message: (GameState, GameState, String) -> String = { "\($0) is not equal to \($1). Fen: \($2)" },
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard let testee else {
            Issue.record("testee is nil", sourceLocation: sourceLocation)
            return
        }
        let gameState = testee.getGameState()
        guard gameState != expectedState else { return }
        Issue.record("\(message(gameState, expectedState, fen))", sourceLocation: sourceLocation)
    }

    func figureExist(_ figure: any ChessFigure, testee: ChessGame) -> Bool {
        testee.figures.contains(where: { $0.equals(figure) })
    }

    func loadFen(_ fen: String, sourceLocation: SourceLocation = #_sourceLocation) {
        guard let position = PositionFactory.loadPosition(fen) else {
            Issue.record("Invalid FEN: \(fen)", sourceLocation: sourceLocation)
            return
        }
        testee = ChessGame(position)
    }
}
