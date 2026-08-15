import Foundation
import os

class ChessBoard {

    private let logger = Log.logger("ChessBoard")

    private(set) var position: Position
    private var moves: [Move] = []
    private var moveLog: [String] = []
    private var positionCount: [Int: Int] = [:]

    init(_ pos: Position) {
        position = pos
        positionCount = [:]
    }

    func move(_ moveNotation: String) throws {
        guard let createdMove = MoveFactory.create(moveNotation, position: position) else {
            throw ValidationError.CanNotIdentifyMove
        }
        try move(createdMove)
    }

    private var validator: MoveValidator {
        MoveValidator(position)
    }

    /// A move has been applied to the board (the position is no longer the untouched start).
    private var hasStarted: Bool {
        position.moveClock > 0
    }

    func move(_ move: Move) throws {
        guard validator.isLegalMove(move) else {
            logger.error("move (\(move.info()) -> \(NotationFactory.generate(move, position: self.position))) is not allowed")
            throw ValidationError.MoveNotLegalMoveOnTheBoard
        }
        logMove(move)
        try doMove(move)
    }

    func getGameState() -> GameState {
        if DrawConditionEvaluator.isInsufficientMaterial(figures: position.getFigures()) {
            return .DrawByInsufficientMaterial
        }
        if !hasStarted {
            return .NotStarted
        }
        if DrawConditionEvaluator.isThreefoldRepetition(positionCount: positionCount, currentHash: position.getHash()) {
            return .DrawByRepetition
        }
        if DrawConditionEvaluator.has50MoveRuleTriggered(halfmoveClock: position.halfmoveClock) {
            return .DrawBy50MoveRule
        }
        if validator.playerHasLegalMove() {
            return .Running
        }
        if validator.isKingInCheck() {
            return position.colorToMove == .white ? .BlackWins : .WhiteWins
        }
        return .DrawByStalemate
    }

    func getPossibleMoves(forPiece: any ChessFigure) -> [Move] {
        return forPiece.getPossibleMoves().filter({ validator.isLegalMove($0) })
    }

    var colorToMove: PieceColor {
        position.colorToMove
    }

    func getFigures() -> [any ChessFigure] {
        return position.getFigures()
    }

    func getMoves() -> [Move] {
        return moves
    }

    func getMoveLog() -> [String] {
        return moveLog
    }

    private func doMove(_ move: Move) throws {
        guard position.get(atRow: move.piece.row, atFile: move.piece.file) != nil else {
            throw ValidationError.FigureDoesNotExist(move.piece)
        }
        position = position.applying(move)
        moves += [move]
        increasePositionCount()
    }

    private func increasePositionCount() {
        let hash = position.getHash()
        positionCount[hash, default: 0] += 1
    }

    private func logMove(_ move: Move) {
        let logInfo = NotationFactory.generate(move, position: position)
        logger.log("play \(logInfo) \(move.info())")
        moveLog += [logInfo]
    }
}
