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

    private var figures:[Figure] = []
    private var boardDict:[Int:[Int:Figure]] = [:]
    private var colorToMove:PieceColor = .white
    private var moves: [Move] = []
    
    public init(_ pos:Position) {
        colorToMove = pos.colorToMove
        figures.append(contentsOf: pos.figures)
        recreateBoardDict()
    }

    public func move(_ move:Move) throws {
        
        guard IsMoveLegalMoveOnTheBoard(move) else {
            logger.error("move (\(move.piece.ident())\(move.piece.getField()) -> \(move.info())) is not allowed")
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
    
    func getPossibleMoves(forPeace:Figure) -> [Move] {
        guard let piece = figures.first(where: { $0 == forPeace }) else {
            logger.error("Piece not found on the board")
            return []
        }
        let moves = piece.getPossibleMoves()
        return moves.filter({ IsMoveLegalMoveOnTheBoard($0) })
    }
    
    public func getFigures() -> [Figure] {
        return figures
    }
    
    private func IsMoveLegalMoveOnTheBoard(_ target:Move) -> Bool {
        if !isMoveInBoard(target) {
            logger.debug("move would jump out of the board")
            return false
        }
        
        if !isMovePossible(target) {
            logger.debug("not possible")
            return false
        }
        
        if doesMovePutOwnKingInCheck(target) {
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
        guard let figure = figures.first(where: { $0 == move.piece }) else {
            logger.warning("figure not found")
            return
        }
        figure.move(row: move.row, file: move.file)
        moveRookForCastling(move)
        recreateBoardDict()
        LogMove(move)
    }
    
    
    private func checkPromotion(_ move: Move) {
        guard move.piece.getType() == .pawn else {
            logger.debug("only Pawns can promote")
            return
        }
        guard pawnHasReachedEndOfTheBoard(move) else {
            logger.debug("pawn needs to travel to the end")
            return
        }

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
        switch move.piece.getType() {
            case .pawn:
                return canPawnMove(to:move)
            case .king:
                return canKingMove(to:move)
            case .bishop, .knight, .rook, .queen:
                return canMove(move)
        }
    }
    
    private func captureFigureAt(row: Int, file: Int) {
        guard let figureAtTarget = getFigure(atRow: row, atFile: file) else { return }
        removeFigure(figureAtTarget)
        logger.info("\(String(describing: figureAtTarget.getColor())) \(String(describing:figureAtTarget.getType())) at \(row):\(file) got captured")
    }
    
    private func moveRookForCastling(_ move: Move) {
        
        guard isKingCastling(move) else { return }
        
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
    
    private func doesMovePutOwnKingInCheck(_ target:Move) -> Bool {
        
        guard let king = figures.first(where: { $0.getType() == .king && $0.getColor() == target.piece.getColor() }) else {
            logger.error("we dont have a king?")
            return false
        }
        
        pretendMove(target)
        let isKingInCheck = isFieldInCheck(king.getRow(), king.getFile())
        recreateBoardDict()
        return isKingInCheck
    }
    
    private func canPawnMove(to: Move) -> Bool {
        guard to.piece.canDo(move: to) else { return false }
        let once = canPawnMoveOnce(to)
        let twice = canPawnMoveTwice(to)
        let capture = canPawnCapture(to, lastMove: moves.last)
        return once || twice || capture
    }
    
    private func canKingMove(to:Move) -> Bool {
        guard canMove(to) else { return false }
        if isShortCastling(to) {
            return canCastle(to, rookStart: Rook.ShortCastleStartingFile)
        } else if isLongCastling(to) {
            return canCastle(to, rookStart: Rook.LongCastleEndFile)
        }
        return true
    }
    
    private func canMove(_ move: Move) -> Bool {
        guard move.piece.canDo(move: move) else {
            return false
        }
        guard let intersectingPiece = getNextPieceOnTheWay(move) else {
            return true
        }
        
        return isCaptureablePiece(move, pieceToCapture: intersectingPiece)
    }
    
    private func canPawnCapture(_ move:Move, lastMove:Move?) -> Bool {
        guard move.type == .Normal || move.type == .Promotion else { return false }
        
        let row = move.piece.getRow() + (move.piece.getColor() == PieceColor.white ? +1 : -1)
        let leftFile = move.piece.getFile() - 1
        let rightFile = move.piece.getFile() + 1
        
        let figureToCaptureOnLeft = hasFigure(atRow: row, atFile: leftFile)
        let figureToCaptureOnRight = hasFigure(atRow: row, atFile: rightFile)
        
        
        let canEnPassant = canEnPassant(move, lastMove: moves.last)
        
        return (figureToCaptureOnLeft && leftFile == move.file) || (figureToCaptureOnRight && rightFile == move.file) || canEnPassant
    }
    
    private func canEnPassant(_ move:Move, lastMove:Move?) -> Bool {
        guard let lastMove = lastMove else {
            logger.debug("no en passant if there is no last move")
            return false
        }
        
        let piece = move.piece
        let movedOnce = move.type != .Double
        let lastMoveToLeft = lastMove.row == piece.getRow() && lastMove.file - piece.getFile() == -1
        let lastMoveToRight = lastMove.row == piece.getRow() && lastMove.file - piece.getFile() == 1
        let enPassantIsPossible = lastMove.piece.getType() == .pawn && lastMove.type == .Double
        let canEnPassantToLeft = movedOnce && enPassantIsPossible && lastMoveToLeft && move.file - piece.getFile() == -1
        let canEnPassantToRight = movedOnce && enPassantIsPossible && lastMoveToRight && move.file - piece.getFile() == 1
        return canEnPassantToLeft || canEnPassantToRight
    }
    
    private func canCastle(_ to: Move, rookStart:Int) -> Bool {
        let isNotCastlingInCheck = isCastlingInCheck(to) == false
        let kingHasNotMovedYet = figureHasNotMoved(King(color: to.piece.getColor(), row: to.piece.getRow(), file: to.piece.getFile()))
        let rookHasNotMovedYet = figureHasNotMoved(Rook(color: to.piece.getColor(), row: to.piece.getRow(), file: Rook.ShortCastleStartingFile))
        return isNotCastlingInCheck && kingHasNotMovedYet && rookHasNotMovedYet
    }

    private func isCastlingInCheck(_ move:Move) -> Bool {
         
        let isLongCastle = isLongCastling(move)
        
        guard !isFieldInCheck(move.piece.getRow(), move.piece.getFile()) else {
            logger.debug("King starts in check for castling")
            return true
        }
        guard !isFieldInCheck(move.row, isLongCastle ? move.file + 1 : move.file - 1) else {
            logger.debug("King whould have move through check by castling")
            return true
        }
        guard !isFieldInCheck(move.row, move.file) else {
            logger.debug("King would land in check by castling")
            return true
        }
        
        return false
    }
    
    private func getNextPieceOnTheWay(_ move: Move) -> Figure? {
        let deltaFile = abs(move.piece.getFile() - move.file)
        let deltaRow = abs(move.piece.getRow() - move.row)
        
        if deltaRow == 0 {
            return getIntersectingPieceOnRow(move)
        } else if deltaFile == 0 {
            return getIntersectingPieceOnFile(move)
        } else if deltaRow == deltaFile {
            return getIntersectingPieceOnDiagonal(move)
        } else if move.piece.getType() == .knight {
            return getFigure(atRow: move.row, atFile: move.file)
        }
        return nil
    }
    
    private func getIntersectingPieceOnRow(_ move: Move) -> Figure? {
        for f in stride(from: move.piece.getFile(), to: move.file, by: move.piece.getFile() < move.file ? 1 : -1)  {
            let foundPiece = getFigure(atRow: move.piece.getRow(), atFile: f)
            if foundPiece != nil && foundPiece! != move.piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceOnFile(_ move: Move) -> Figure? {
        for r in stride(from: move.piece.getRow(), to: move.row, by: move.piece.getRow() < move.row ? 1 : -1) {
            let foundPiece = getFigure(atRow: r, atFile: move.piece.getFile())
            if foundPiece != nil && foundPiece! != move.piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceOnDiagonal(_ move: Move) -> Figure? {
        let rowDir = min(max(move.row - move.piece.getRow(), -1), 1)
        let fileDir = min(max(move.file - move.piece.getFile(), -1), 1)
        let delta = abs(move.piece.getFile() - move.file)
        for i in 1...delta {
            let row = move.piece.getRow()+(i*rowDir)
            let file = move.piece.getFile()+(i*fileDir)
            let foundPiece = getFigure(atRow: row, atFile: file)
            if foundPiece != nil && foundPiece! != move.piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func canPawnMoveOnce(_ move: Move) -> Bool {
        guard move.type == .Normal else { return false }
        guard moveDoesNotChangeFile(move) else { return false }
        return fieldIsEmpty(atRow: move.row, atFile: move.file)
    }
    
    private func canPawnMoveTwice(_ move: Move) -> Bool {
        guard move.type == .Double else { return false }
        guard !move.piece.hasMoved() else { return false }
        guard moveDoesNotChangeFile(move) else { return false }
        guard fieldIsEmpty(atRow: move.row, atFile: move.file) else { return false }
        
        if move.piece.getColor() == PieceColor.white {
            return fieldIsEmpty(atRow: move.piece.getRow()+1, atFile: move.file)
        } else {
            return fieldIsEmpty(atRow: move.piece.getRow()-1, atFile: move.file)
        }
    }
    
    private func isFieldInCheck(_ row: Int, _ file: Int) -> Bool {
        return figures.contains(where: {  $0.getColor() != colorToMove && isMovePossible(Move(row, file, piece: $0)) })
    }
    
    private func figureHasNotMoved(_ fig: Figure) -> Bool {
        let foundFigure = figures.first(where: { $0 == fig })
        return foundFigure?.hasMoved() == false
    }
    
    private func isCaptureablePiece(_ move: Move, pieceToCapture: Figure?) -> Bool {
        return move.piece.getColor() != pieceToCapture!.getColor() && pieceToCapture!.getRow() == move.row && pieceToCapture!.getFile() == move.file
    }
    
    private func moveDoesNotChangeFile(_ move:Move) -> Bool {
        return move.file == move.piece.getFile()
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
    
    private func hasFigure(atRow:Int, atFile:Int) -> Bool {
        return getFigure(atRow: atRow, atFile: atFile) != nil
    }
    
    private func fieldIsEmpty(atRow:Int, atFile:Int) -> Bool {
        return hasFigure(atRow: atRow, atFile: atFile) == false
    }
    
    private func getFigure(atRow:Int, atFile:Int) -> Figure? {
        return boardDict[atRow]?[atFile]
    }
    
    private func addFigure(_ to: Figure) {
        figures.append(to)
    }
    
    private func removeFigure(_ figure:Figure) {
        guard let index = figures.firstIndex(where: { $0 == figure }) else {
            logger.error("cant remove figure (\(figure.info())) because it doesnt exist")
            return
        }
        figures.remove(at: index)
    }
    
    private func pretendMove(_ target: Move) {
        boardDict[target.piece.getRow()]![target.piece.getFile()] = nil
        if boardDict[target.row] == nil {
            boardDict[target.row] = [:]
        }
        boardDict[target.row]![target.file] = target.piece
    }

    private func recreateBoardDict(){
        var dict:[Int:[Int:Figure]] = [:]
        for f in figures {
            if dict[f.getRow()] == nil {
                dict[f.getRow()] = [:]
            }
            dict[f.getRow()]![f.getFile()] = f
        }
        boardDict = dict
    }
}
