import Foundation
import os

public class ChessGame {

    private let logger = Log.logger("ChessBoard")

    private var positionCount: [Int: Int] = [:]
    private var hasStarted: Bool { position.moveClock > 0 }

    public private(set) var position: Position
    public private(set) var moveLog: [String] = []
    public var colorToMove: PieceColor { position.colorToMove }
    public var figures:[any ChessPiece] { position.figures }

    public init(_ pos: Position) {
        position = pos
        positionCount = [pos.getHash(): 1]
    }

    public func move(_ moveNotation: String) throws {
        guard let createdMove = MoveFactory.create(moveNotation, position: position) else {
            logger.error("can not identify move: \(moveNotation)")
            throw ValidationError.canNotIdentifyMove
        }
        try move(createdMove)
    }

    public func move(_ move: Move) throws {
        let validator = MoveValidator(position)
        guard validator.isLegalMove(move) else {
            logger.error("move (\(move.info) -> \(NotationFactory.generate(move, position: self.position))) is not allowed")
            throw ValidationError.moveNotLegalMoveOnTheBoard
        }
        guard validator.figureExists(move) else {
            logger.error("figure \(move.piece.info()) does not exists")
            throw ValidationError.pieceDoesNotExist(move.piece)
        }
        try doMove(move)
    }

    public func getGameState() -> GameState {
        if DrawConditionEvaluator.isInsufficientMaterial(figures: position.figures) {
            return .drawByInsufficientMaterial
        }
        if !hasStarted {
            return .notStarted
        }
        if DrawConditionEvaluator.isThreefoldRepetition(positionCount: positionCount, currentHash: position.getHash()) {
            return .drawByRepetition
        }
        if DrawConditionEvaluator.has50MoveRuleTriggered(halfmoveClock: position.halfmoveClock) {
            return .drawBy50MoveRule
        }
        let validator = MoveValidator(position)
        if validator.playerHasLegalMove() {
            return .running
        }
        if validator.isKingInCheck() {
            return position.colorToMove == .white ? .blackWins : .whiteWins
        }
        return .drawByStalemate
    }

    public func getPossibleMoves(forPiece: any ChessPiece) -> [Move] {
        let validator = MoveValidator(position)
        return forPiece.getPossibleMoves().filter({ validator.isLegalMove($0) })
    }

    private func doMove(_ move: Move) throws {
        logMove(move)
        position = position.applying(move)
        increasePositionCount()
    }

    private func logMove(_ move: Move) {
        let logInfo = NotationFactory.generate(move, position: position)
        logger.log("play \(logInfo) \(move.info)")
        moveLog += [logInfo]
    }

    private func increasePositionCount() {
        let hash = position.getHash()
        positionCount[hash, default: 0] += 1
    }
}
