import Foundation
import os

class ChessGame {

    private let logger = Log.logger("ChessBoard")

    private var positionCount: [Int: Int] = [:]
    private var validator: MoveValidator { MoveValidator(position) }
    private var hasStarted: Bool { position.moveClock > 0 }
    
    private(set) var position: Position
    private(set) var moveLog: [String] = []
    var colorToMove: PieceColor { position.colorToMove }
    var figures:[any ChessFigure] { position.figures }

    init(_ pos: Position) {
        position = pos
        positionCount = [:]
    }

    func move(_ moveNotation: String) throws {
        guard let createdMove = MoveFactory.create(moveNotation, position: position) else {
            logger.error("can not identify move: \(moveNotation)")
            throw ValidationError.CanNotIdentifyMove
        }
        try move(createdMove)
    }

    func move(_ move: Move) throws {
        guard validator.isLegalMove(move) else {
            logger.error("move (\(move.info) -> \(NotationFactory.generate(move, position: self.position))) is not allowed")
            throw ValidationError.MoveNotLegalMoveOnTheBoard
        }
        guard validator.figureExists(move) else {
            logger.error("figure \(move.piece.info()) does not exists")
            throw ValidationError.FigureDoesNotExist(move.piece)
        }
        try doMove(move)
    }

    func getGameState() -> GameState {
        if DrawConditionEvaluator.isInsufficientMaterial(figures: position.figures) {
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
