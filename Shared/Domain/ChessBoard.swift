//
//  ChessBoard.swift
//  SwiftChess
//
//  Created by Jan Fässler on 04.03.2024.
//

import Foundation
import os

public class ChessBoard {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ChessBoard")

    private var figures:[ChessFigure] = []
    private var cache:BoardCache
    private var colorToMove:PieceColor = .white
    private var moves: [Move] = []
    private var moveLog: [String] = []
    
    public init(_ pos:Position) {
        colorToMove = pos.colorToMove
        figures.append(contentsOf: pos.figures)
        cache = BoardCache.create(figures)
    }
    
    public func move(_ moveNotation:String) throws {
        guard let createdMove = MoveFactory.create(moveNotation, cache: cache) else {
            throw ValidationError.CanNotIdentifyMove
        }
        try move(createdMove)
    }

    public func move(_ move:Move) throws {
        
        guard IsMoveLegalMoveOnTheBoard(move) else {
            logger.error("move (\(move.piece.ident())\(move.piece.getFieldInfo()) -> \(move.info())) is not allowed")
            throw ValidationError.MoveNotLegalMoveOnTheBoard
        }

        let isCapture = doCapture(move)
        try doMove(move)

        LogMove(move, isCapture: isCapture)

    }
    
    public func getColorToMove() -> PieceColor {
        return colorToMove
    }
    
    public func getPossibleMoves(forPeace:any ChessFigure) -> [Move] {
        guard let piece = figures.first(where: { $0.equals(forPeace) }) else {
            return []
        }
        let moves = piece.getPossibleMoves()
        return moves.filter({ IsMoveLegalMoveOnTheBoard($0) })
    }
    
    public func getFigures() -> [ChessFigure] {
        return figures
    }
    
    public func getMoves() -> [Move] {
        return moves
    }
    public func getMoveLog() -> [String] {
        return moveLog
    }
    
    private func IsMoveLegalMoveOnTheBoard(_ target:Move) -> Bool {
        guard isMoveInBoard(target) else {
            logger.debug("move '\(target.info())' would jump out of the board")
            return false
        }
        
        guard target.piece.isMovePossible(target, cache: getBoardCache()) else {
            logger.debug("move '\(target.info())' is not possible")
            return false
        }
        
        guard !doesMovePutOwnKingInCheck(target) else {
            logger.debug("move '\(target.info())' would set own king in check")
            return false
        }
        
        return true
    }
    
    private func doCapture(_ move: Move) -> Bool {
        if isPawnCapturing(move) {
            return captureFigureAt(row: move.piece.getRow(), file: move.file)
        }
        
        return captureFigureAt(row: move.row, file: move.file)
    }

    private func doMove(_ move: Move) throws {
        let figure = figures.first(where: { $0.equals(move.piece) })!
        figure.move(row: move.row, file: move.file)
        moveRookForCastling(move)
        colorToMove = colorToMove == .black ? .white : .black
        moves += [move]
        cache = getBoardCache()
    }
    
    private func checkPromotion(_ move: Move) -> Bool {
        guard move.piece.getType() == .pawn else { return false }
        guard pawnHasReachedEndOfTheBoard(move) else { return false  }

        // Todo: Promotion Choice
        promote(Pawn(color: move.piece.getColor(), row: move.getRow(), file: move.getFile()), to: Queen(color: move.piece.getColor(), row: move.row, file: move.file))
        return true
    }
    
    private func captureFigureAt(row: Int, file: Int) -> Bool {
        guard let figureAtTarget = getFigure(atRow: row, atFile: file) else { return false }
        removeFigure(figureAtTarget)
        logger.info("\(String(describing: figureAtTarget.getColor())) \(String(describing:figureAtTarget.getType())) at \(row):\(file) got captured")
        return true
    }
    
    private func moveRookForCastling(_ move: Move) {
    
        if isLongCastling(move) {
            let rook = getFigure(atRow:move.piece.getRow(), atFile: Rook.LongCastleStartingFile)!
            rook.move(row: move.row, file: Rook.LongCastleEndFile)
        } else if isShortCastling(move) {
            let rook = getFigure(atRow:move.piece.getRow(), atFile: Rook.ShortCastleStartingFile)!
            rook.move(row: move.row, file: Rook.ShortCastleEndFile)
        }
    }
    
    private func promote(_ pawn: Figure, to:Figure) {
        removeFigure(pawn)
        addFigure(to)
    }
    
    private func doesMovePutOwnKingInCheck(_ move:Move) -> Bool {
        
        let isKingMKove = move.piece.getType() == .king
        let king = figures.first(where: { $0.getType() == .king && $0.getColor() == move.piece.getColor() })!
        let rowToCheck = isKingMKove ? move.getRow() : king.getRow()
        let fileToCheck = isKingMKove ? move.getFile() : king.getFile()
        
                
        let modifiedCache = createCacheWithMove(move)
        
        return figures.contains(where: {
            if $0.getColor() != colorToMove {
                if $0.isMovePossible($0.createMove(rowToCheck, fileToCheck, MoveType.Normal), cache: modifiedCache) {
                    return true
                } else {
                    return false
                }
            }
            return false
        })
    }
    
    private func createCacheWithMove(_ move:Move) -> BoardCache {
        let cache = getBoardCache()
        cache.clearField(atRow: move.piece.getRow(), atFile: move.piece.getFile())
        cache.set(Figure(type: move.piece.getType(), color: move.piece.getColor(), row: move.getRow(), file: move.getFile()))
        return cache
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
        return move.file == King.LongCastlePosition && isKingCastling(move)
    }
    
    private func isShortCastling(_ move: Move) -> Bool {
        return move.file == King.ShortCastlePosition && isKingCastling(move)
    }
    
    private func fieldIsEmpty(atRow:Int, atFile:Int) -> Bool {
        return hasFigure(atRow: atRow, atFile: atFile) == false
    }
    
    private func hasFigure(atRow:Int, atFile:Int) -> Bool {
        return getFigure(atRow: atRow, atFile: atFile) != nil
    }
    
    private func getFigure(atRow:Int, atFile:Int) -> ChessFigure? {
        return cache.get(atRow: atRow, atFile: atFile)
    }
    
    private func addFigure(_ to: ChessFigure) {
        figures.append(to)
    }
    
    private func removeFigure(_ figure:ChessFigure) {
        figures.removeAll(where: { $0.equals(figure) })
    }

    private func getBoardCache() -> BoardCache {
        return BoardCache.create(figures, lastMove: moves.last)
    }
    
    private func LogMove(_ move: Move, isCapture:Bool) {
        let isPromotion = checkPromotion(move)
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
                logInfo.append("+")
            }
        }
        logger.log("\(logInfo)")
        moveLog += [logInfo]
    }
    
    private func isCheck(_ move:Move) -> Bool {
        let opponentKing = figures.first(where: { $0.getType() == .king && $0.getColor() != move.piece.getColor()})
        return cache.isFieldInCheck(opponentKing!.getRow(), opponentKing!.getFile())
    }
}
