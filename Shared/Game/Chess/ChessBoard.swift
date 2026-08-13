import Foundation
import os

class ChessBoard {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ChessBoard")

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
        let moves = forPiece.getPossibleMoves()
        return moves.filter({ position.isLegalMove($0) })
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
        let figure = position.get(atRow: move.getPiece().getRow(), atFile: move.getPiece().getFile())!
        let capturedPiece = doCapture(move)

        figure.move(row: move.row, file: move.file)
        handlePromotion(move)
        relocateCastlingRook(move)
        moves += [move]
        updateBoardStates(move, capturedPiece: capturedPiece)
    }

    private func handlePromotion(_ move: Move) {
        guard move.piece.getType() == .pawn else { return }
        let targetRow = move.getRow()
        guard (move.piece.getColor() == .white && targetRow == 8) ||
              (move.piece.getColor() == .black && targetRow == 1) else { return }
        position.clearField(atRow: move.piece.getRow(), atFile: move.piece.getFile())
        position.set(Figure.create(type: move.promoteTo, color: move.piece.getColor(), row: targetRow, file: move.getFile()))
    }

    private func relocateCastlingRook(_ move: Move) {
        if position.isLongCastling(move) {
            moveRook(fromFile: Rook.CastleQueensideStartingFile, toFile: Rook.CastleQueensideEndFile, row: move.row)
        } else if position.isShortCastling(move) {
            moveRook(fromFile: Rook.CastleKingsideStartingFile, toFile: Rook.CastleKingsideEndFile, row: move.row)
        }
    }

    private func moveRook(fromFile: Int, toFile: Int, row: Int) {
        guard let rook = position.get(atRow: row, atFile: fromFile) else { return }
        rook.move(row: row, file: toFile)
        position.clearField(atRow: row, atFile: fromFile)
        position.set(rook)
    }
    
    private func doCapture(_ move: Move) -> (any ChessFigure)? {
        if isPawnCapturing(move) {
            return captureFigureAt(row: move.piece.getRow(), file: move.file)
        }
        return captureFigureAt(row: move.row, file: move.file)
    }
    
    private func updateBoardStates(_ move: Move, capturedPiece: (any ChessFigure)?) {
        position = PositionFactory.create(position, afterMove: move, figures: position.getFigures(), capturedPiece: capturedPiece)
        increasePositionCount()
    }
    
    private func captureFigureAt(row: Int, file: Int) -> (any ChessFigure)? {
        guard let figureAtTarget = position.get(atRow: row, atFile: file) else { return nil }
        removeFigure(figureAtTarget)
        logger.info("\(String(describing: figureAtTarget.getColor())) \(String(describing: figureAtTarget.getType())) at \(row):\(file) got captured")
        return figureAtTarget
    }
    
    private func isPawnCapturing(_ move: Move) -> Bool {
        return move.piece.getType() == PieceType.pawn && move.piece.getFile() != move.file && fieldIsEmpty(atRow: move.row, atFile: move.file)
    }
    
    private func fieldIsEmpty(atRow: Int, atFile: Int) -> Bool {
        return hasFigure(atRow: atRow, atFile: atFile) == false
    }
    
    private func hasFigure(atRow: Int, atFile: Int) -> Bool {
        return position.get(atRow: atRow, atFile: atFile) != nil
    }
    
    private func removeFigure(_ figure: any ChessFigure) {
        position.clearField(atRow: figure.getRow(), atFile: figure.getFile())
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
