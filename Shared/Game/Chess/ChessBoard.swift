import Foundation
import os

class ChessBoard {

    private let logger = Log.logger("ChessBoard")

    private var position: Position
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

    func move(_ move: Move) throws {
        guard position.isLegalMove(move) else {
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
        if position.getMoveClock() == 0 {
            return .NotStarted
        }
        if DrawConditionEvaluator.isThreefoldRepetition(positionCount: positionCount, currentHash: position.getHash()) {
            return .DrawByRepetition
        }
        if DrawConditionEvaluator.has50MoveRuleTriggered(halfmoveClock: position.getHalfmoveClock()) {
            return .DrawBy50MoveRule
        }
        if position.playerHasLegalMove() {
            return .Running
        }
        if position.isKingInCheck() {
            return position.getColorToMove() == .white ? .BlackWins : .WhiteWins
        }
        return .DrawByStalemate
    }

    func getPossibleMoves(forPiece: any ChessFigure) -> [Move] {
        return forPiece.getPossibleMoves().filter({ position.isLegalMove($0) })
    }

    func getColorToMove() -> PieceColor {
        return position.getColorToMove()
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

    func getPosition() -> Position {
        return position
    }

    private func doMove(_ move: Move) throws {
        guard position.get(atRow: move.getPiece().getRow(), atFile: move.getPiece().getFile()) != nil else {
            throw ValidationError.FigureDoesNotExist(move.getPiece())
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
