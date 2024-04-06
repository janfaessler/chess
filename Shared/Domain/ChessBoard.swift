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
        
        guard IsMoveLegalMoveOnTheBoard(move) else {
            logger.error("move (\(move.piece.ident())\(move.piece.getFieldInfo()) -> \(move.info())) is not allowed")
            throw ValidationError.MoveNotLegalMoveOnTheBoard
        }

        let isCapture = try doMove(move)
        let isPromotion = checkPromotion(move)

        LogMove(move, isCapture: isCapture, isPromotion: isPromotion)

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
        
        if playerHasLegalMove() {
            return .Running
        }

        if isKingInCheck() {
            return position.getColorToMove() == .white ? .BlackWins : .WhiteWins
        }
        
        return .DrawByStalemate
    }
    
    public func getPossibleMoves(forPeace:any ChessFigure) -> [Move] {
        let moves = forPeace.getPossibleMoves()
        return moves.filter({ IsMoveLegalMoveOnTheBoard($0) })
    }
    
    public func getColorToMove() -> PieceColor {
        return position.getColorToMove()
    }
    
    public func getFigures() -> [any ChessFigure] {
        return position.getFigures()
    }
    
    public func getMoveLog() -> [String] {
        return moveLog
    }
    
    public func getPosition() -> Position {
        return position
    }
    
    private func IsMoveLegalMoveOnTheBoard(_ target:Move) -> Bool {
        guard isMoveInBoard(target) else {
            logger.debug("move '\(target.info())' would jump out of the board")
            return false
        }
        
        guard target.piece.isMovePossible(target, position: position) else {
            logger.debug("move '\(target.info())' is not possible")
            return false
        }
        
        guard !doesMovePutOwnKingInCheck(target) else {
            logger.debug("move '\(target.info())' would set own king in check")
            return false
        }
        
        return true
    }
    
    private func doMove(_ move: Move) throws -> Bool {
        let figure = position.get(atRow: move.getPiece().getRow(), atFile: move.getPiece().getFile())!
        let capturedPiece = doCapture(move)

        figure.move(row: move.row, file: move.file)
        moveRookForCastling(move)
        moves += [move]
        updateBoardStates(move, capturedPiece: capturedPiece)
        return capturedPiece != nil
    }
    
    private func doCapture(_ move: Move) -> (any ChessFigure)? {
        if isPawnCapturing(move) {
            return captureFigureAt(row: move.piece.getRow(), file: move.file)
        }
        
        return captureFigureAt(row: move.row, file: move.file)
    }

    private func checkPromotion(_ move: Move) -> Bool {
        guard 
            move.piece.getType() == .pawn,
            pawnHasReachedEndOfTheBoard(move)
        else { return false }

        promote(Pawn(color: move.piece.getColor(), row: move.getRow(), file: move.getFile()),
                to: Figure.create(type: move.promoteTo, color: move.piece.getColor(), row: move.getRow(), file: move.getFile()))
        return true
    }
    
    private func updateBoardStates(_ move: Move, capturedPiece: (any ChessFigure)?) {
        
        position = PositionFactory.create(position, afterMove: move, capturedPiece: capturedPiece)
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
    
    private func moveRookForCastling(_ move: Move) {
    
        if isLongCastling(move) {
            let rook = position.get(atRow: move.piece.getRow(), atFile: Rook.CastleQueensideStartingFile)!
            rook.move(row: move.row, file: Rook.CastleQueensideEndFile)
            position.clearField(atRow: move.piece.getRow(), atFile: Rook.CastleQueensideStartingFile)
            position.set(rook)
        } else if isShortCastling(move) {
            let rook = position.get(atRow: move.piece.getRow(), atFile: Rook.CastleKingsideStartingFile)!
            rook.move(row: move.row, file: Rook.CastleKingsideEndFile)
            position.clearField(atRow: move.piece.getRow(), atFile: Rook.CastleKingsideStartingFile)
            position.set(rook)
        }
    }
    
    private func promote(_ pawn: Figure, to:any ChessFigure) {
        removeFigure(pawn)
        addFigure(to)
    }
    
    private func doesMovePutOwnKingInCheck(_ move:Move) -> Bool {
        
        let isKingMKove = move.piece.getType() == .king
        let figures = position.getFigures()
        let king = figures.first(where: { $0.getType() == .king && $0.getColor() == move.piece.getColor() })!
        let rowToCheck = isKingMKove ? move.getRow() : king.getRow()
        let fileToCheck = isKingMKove ? move.getFile() : king.getFile()
                
        let newPos = createPositionWithMove(move)
        
        return figures.contains(where: {
            if $0.getColor() != position.getColorToMove() {
                if $0.isMovePossible($0.createMove(rowToCheck, fileToCheck, MoveType.Normal), position: newPos) {
                    return true
                } else {
                    return false
                }
            }
            return false
        })
    }
    
    private func createPositionWithMove(_ move:Move) -> Position {
        let capturedPiece = position.get(atRow: move.getRow(), atFile: move.getFile())
        
        var figures = position.getFigures()
        figures.removeAll(where: { $0.equals(move.getPiece()) })
        figures.append(Figure.create(type: move.getPiece().getType(), color: move.getPiece().getColor(), row: move.getRow(), file: move.file, moved: true))
        
        let pos = PositionFactory.create(position, afterMove: move, figures: figures, capturedPiece: capturedPiece)

        return pos
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
    
    private func isMoveInBoard(_ move:Move) -> Bool {
        return 1...8 ~= move.row && 1...8 ~= move.file
    }
    
    private func pawnHasReachedEndOfTheBoard(_ move:Move) -> Bool {
        return (move.piece.getColor() == .white && move.row == 8) || (move.piece.getColor() == .black && move.row == 1)
    }
    
    private func isKingCastling(_ move: Move) -> Bool {
        return move.piece.getType() == .king && move.type == .Castle
    }
    
    private func isLongCastling(_ move: Move) -> Bool {
        return move.file == King.CastleQueensidePosition && isKingCastling(move)
    }
    
    private func isShortCastling(_ move: Move) -> Bool {
        return move.file == King.CastleKingsidePosition && isKingCastling(move)
    }
    
    private func playerHasLegalMove() -> Bool {
        let figuresOfCurrentPlayer = position.getFigures().filter({ $0.getColor() == position.getColorToMove() })
        return figuresOfCurrentPlayer.contains(where: { fig in fig.getPossibleMoves().contains(where: { move in IsMoveLegalMoveOnTheBoard(move) }) })
    }
    
    private func isKingInCheck() -> Bool {
        let king = position.getFigures().first(where: { $0.getType() == .king && $0.getColor() == position.getColorToMove()})!
        return position.isFieldInCheck(king.getRow(), king.getFile())
    }
    
    private func isThreefoldRepetition() -> Bool {
        let hash = position.getHash()
        let count = positionCount[hash] ?? 0
        return  count >= 3
    }
    
    private func is50MoveWithoutPawnOrCaptureDone() -> Bool {
        return position.getHalfmoveClock() > 100
    }
    
    private func isCheck(_ move:Move) -> Bool {
        let opponentKing = position.getFigures().first(where: { $0.getType() == .king && $0.getColor() != move.piece.getColor()})
        return position.isFieldInCheck(opponentKing!.getRow(), opponentKing!.getFile())
    }
    
    private func fieldIsEmpty(atRow:Int, atFile:Int) -> Bool {
        return hasFigure(atRow: atRow, atFile: atFile) == false
    }
    
    private func hasFigure(atRow:Int, atFile:Int) -> Bool {
        return position.get(atRow: atRow, atFile: atFile) != nil
    }
    
    private func addFigure(_ to: any ChessFigure) {
        position.set(to)
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
    
    private func LogMove(_ move: Move, isCapture:Bool, isPromotion:Bool) {
        let isCheck = isCheck(move)

        var logInfo:String = ""
        if move.type == .Castle {
            logInfo.append(move.info())
        } else {
            logInfo.append("\(move.piece.ident())")
            
            if isCapture {
                if move.piece.getType() == .pawn {
                    logInfo.append(move.getStartingField().getFileName())
                }
                logInfo.append("x")
            }
            logInfo.append(move.getFieldInfo())

            if isPromotion {
                logInfo.append("=\(Queen.Ident)")
            }
            
            if isCheck {
                if getGameState() == .Running {
                    logInfo.append("+")
                } else {
                    logInfo.append("#")
                }
            }
        }
        logger.log("\(logInfo)")
        moveLog += [logInfo]
    }
}
