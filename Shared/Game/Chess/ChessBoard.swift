import Foundation
import os

public class ChessBoard {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ChessBoard")

    private var position:Position
    private var moves: [Move] = []
    private var moveLog: [String] = []
    private var positionCount:[Int:Int] = [:]
    
    public init(_ pos:Position) {
        position = pos
        positionCount = [:]
    }
    
    public func move(_ moveNotation:String) throws {
        guard let createdMove = MoveFactory.create(moveNotation, position: position) else {
            throw ValidationError.CanNotIdentifyMove
        }
        try move(createdMove)
    }

    public func move(_ move:Move) throws {
        guard position.IsMoveLegalMoveOnTheBoard(move) else {
            logger.error("move (\(move.info()) -> \(NotationFactory.generate(move, position: self.position))) is not allowed")
            throw ValidationError.MoveNotLegalMoveOnTheBoard
        }
        LogMove(move)
        try doMove(move)
    }

    public func getGameState() -> GameState {
        
        if isDrawByInsufficientMaterial() {
            return .DrawByInsufficientMaterial
        }
        
        if position.getMoveClock() == 0 {
            return .NotStarted
        }
        
        if isThreefoldRepetition() {
            return .DrawByRepetition
        }
        
        if is50MoveWithoutPawnOrCaptureDone() {
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
    
    public func getPossibleMoves(forPeace:any ChessFigure) -> [Move] {
        let moves = forPeace.getPossibleMoves()
        return moves.filter({ position.IsMoveLegalMoveOnTheBoard($0) })
    }
    
    public func getColorToMove() -> PieceColor {
        return position.getColorToMove()
    }
    
    public func getFigures() -> [any ChessFigure] {
        return position.getFigures()
    }
    
    public func getMoves() -> [Move] {
        return moves
    }
    
    public func getMoveLog() -> [String] {
        return moveLog
    }
    
    public func getPosition() -> Position {
        return position
    }
    
    private func doMove(_ move: Move) throws {
        let figure = position.get(atRow: move.getPiece().getRow(), atFile: move.getPiece().getFile())!
        let capturedPiece = doCapture(move)

        figure.move(row: move.row, file: move.file)
        position.checkPromotion(move)
        position.moveRookForCastling(move)
        moves += [move]
        updateBoardStates(move, capturedPiece: capturedPiece)
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
    
    private func isDrawByInsufficientMaterial() -> Bool {
        
        return onlyKingsLeft()
            || onlyOneKnightLeft()
            || onlyOneBishopLeft()
            || onlySameColorBishopsLeft()
    }
    
    private func captureFigureAt(row: Int, file: Int) -> (any ChessFigure)? {
        guard let figureAtTarget = position.get(atRow: row, atFile: file) else { return nil }
        removeFigure(figureAtTarget)
        logger.info("\(String(describing: figureAtTarget.getColor())) \(String(describing:figureAtTarget.getType())) at \(row):\(file) got captured")
        return figureAtTarget
    }
    
    private func onlyKingsLeft() -> Bool {
        let figures = position.getFigures()
        return figures.filter({ $0.getType() == .king }).count == 2 && figures.count == 2
    }
    
    private func onlyOneKnightLeft() -> Bool {
        let figures = position.getFigures()
        return figures.filter({ $0.getType() == .knight }).count == 1 && figures.count == 3
    }
    
    private func onlyOneBishopLeft() -> Bool {
        let figures = position.getFigures()
        return figures.filter({ $0.getType() == .bishop }).count == 1 && figures.count == 3
    }
    
    private func onlySameColorBishopsLeft() -> Bool {
        let figures = position.getFigures()
        let bishopList = figures.filter({ $0.getType() == .bishop })
        guard 
            bishopList.count == 2,
            Set(bishopList.map({ $0.getColor() })).count == 2
        else { return false }
        let indices = bishopList.map({ ($0.getRow() + $0.getFile()) })
        let modIndices = indices.map({ $0 % 2})
        return Set(modIndices).count == 1
    }
    
    private func isPawnCapturing(_ move: Move) -> Bool {
        return move.piece.getType() == PieceType.pawn && move.piece.getFile() != move.file && fieldIsEmpty(atRow: move.row, atFile: move.file)
    }
    
    private func isThreefoldRepetition() -> Bool {
        let hash = position.getHash()
        let count = positionCount[hash] ?? 0
        return  count >= 3
    }
    
    private func is50MoveWithoutPawnOrCaptureDone() -> Bool {
        return position.getHalfmoveClock() > 100
    }
    
    private func fieldIsEmpty(atRow:Int, atFile:Int) -> Bool {
        return hasFigure(atRow: atRow, atFile: atFile) == false
    }
    
    private func hasFigure(atRow:Int, atFile:Int) -> Bool {
        return position.get(atRow: atRow, atFile: atFile) != nil
    }
    
    private func removeFigure(_ figure:any ChessFigure) {
        position.clearField(atRow: figure.getRow(), atFile: figure.getFile())
    }
    
    private func increasePositionCount() {
        let hash = position.getHash()
        
        guard positionCount[hash] != nil else {
            positionCount[position.getHash()] = 1
            return
        }
        positionCount[position.getHash()] = positionCount[position.getHash()]! + 1
    }
    
    private func LogMove(_ move: Move) {
        let logInfo = NotationFactory.generate(move, position: position)
        logger.log("play \(logInfo) \(move.info())")
        moveLog += [logInfo]
    }
}
