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
    
    public init(_ pos:Position) {
        colorToMove = pos.colorToMove
        figures.append(contentsOf: pos.figures)
        cache = BoardCache.create(figures)
    }

    public func move(_ move:Move) throws {
        
        guard IsMoveLegalMoveOnTheBoard(move) else {
            logger.error("move (\(move.piece.ident())\(move.piece.getFieldInfo()) -> \(move.info())) is not allowed")
            throw ValidationError.MoveNotLegalMoveOnTheBoard
        }

        doCapture(move)
        doMove(move)
        checkPromotion(move)
        setColorToMove()
        moves += [move]
    }
    
    func getColorToMove() -> PieceColor {
        return colorToMove
    }
    
    func getPossibleMoves(forPeace:any ChessFigure) -> [Move] {
        guard let piece = figures.first(where: { $0.equals(forPeace) }) else {
            logger.error("Piece not found on the board")
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
    
    private func IsMoveLegalMoveOnTheBoard(_ target:Move) -> Bool {
        guard isMoveInBoard(target) else {
            logger.debug("move would jump out of the board")
            return false
        }
        
        guard target.piece.isMovePossible(target, cache: getBoardCache()) else {
            logger.debug("not possible")
            return false
        }
        
        guard !doesMovePutOwnKingInCheck(target) else {
            logger.debug("move would set own king in check")
            return false
        }
        
        return true
    }
    
    private func doCapture(_ move: Move) {
        if isPawnCapturing(move) {
            captureFigureAt(row: move.piece.getRow(), file: move.file)
        } else {
            captureFigureAt(row: move.row, file: move.file)
        }
    }

    private func doMove(_ move: Move) {
        guard let figure = figures.first(where: { $0.equals(move.piece) }) else {
            logger.warning("figure not found")
            return
        }
        figure.move(row: move.row, file: move.file)
        moveRookForCastling(move)
        recreateBoardDict()
        LogMove(move)
    }
    
    
    private func checkPromotion(_ move: Move) {
        guard move.piece.getType() == .pawn else { return }
        guard pawnHasReachedEndOfTheBoard(move) else { return }

        // Todo: Promotion Choice
        promote(Pawn(color: move.piece.getColor(), row: move.getRow(), file: move.getFile()), to: Queen(color: move.piece.getColor(), row: move.row, file: move.file))

    }
    
    private func setColorToMove() {
        colorToMove = colorToMove == .black ? .white : .black
    }
    
    private func LogMove(_ move: Move) {
        logger.log("\(move.info())")
    }
    
    private func isMovePossible( _ move: Move) -> Bool {
        return move.piece.isMovePossible(move, cache: getBoardCache())
    }
    
    private func captureFigureAt(row: Int, file: Int) {
        guard let figureAtTarget = getFigure(atRow: row, atFile: file) else { return }
        removeFigure(figureAtTarget)
        logger.info("\(String(describing: figureAtTarget.getColor())) \(String(describing:figureAtTarget.getType())) at \(row):\(file) got captured")
    }
    
    private func moveRookForCastling(_ move: Move) {
    
        if isLongCastling(move) {
            guard let rook = getFigure(atRow: move.piece.getRow(), atFile: Rook.LongCastleStartingFile) else {
                logger.error("no rook able to castle long found")
                return
            }
            rook.move(row: move.row, file: Rook.LongCastleEndFile)
                
        } else if isShortCastling(move) {
            guard let rook = getFigure(atRow:move.piece.getRow(), atFile: Rook.ShortCastleStartingFile) else {
                logger.error("no rook able to castle short found")
                return
            }
            rook.move(row: move.row, file: Rook.ShortCastleEndFile)
        }
    }
    
    private func promote(_ pawn: Figure, to:Figure) {
        removeFigure(pawn)
        addFigure(to)
    }
    
    private func doesMovePutOwnKingInCheck(_ move:Move) -> Bool {
        
        guard let king = figures.first(where: { $0.getType() == .king && $0.getColor() == move.piece.getColor() }) else {
            logger.error("we dont have a king?")
            return false
        }
                
        let modifiedCache = createCacheWithMove(move)
        
        return figures.contains(where: {  $0.getColor() != colorToMove && $0.isMovePossible(Move(king.getRow(), king.getFile(), piece: $0), cache: modifiedCache) })
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
        guard let index = figures.firstIndex(where: { $0.equals(figure) }) else {
            logger.error("cant remove figure (\(figure.info())) because it doesnt exist")
            return
        }
        figures.remove(at: index)
    }
    
    private func recreateBoardDict(){
        cache = getBoardCache()
    }
    
    private func getBoardCache() -> BoardCache {
        return BoardCache.create(figures, lastMove: moves.last)
    }
}
