//
//  ChessBoard.swift
//  SwiftChess
//
//  Created by Jan Fässler on 04.03.2024.
//

import Foundation
import os

class ChessBoard {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ChessBoard")

    private var figures:[Figure] = []
    private var boardDict:[Int:[Int:Figure]] = [:]
    private var colorToMove:PieceColor = .white
    private var moves: [Move] = []
    
    init(_ pos:Position) {
        colorToMove = pos.colorToMove
        figures.append(contentsOf: pos.figures)
        recreateBoardDict()
    }

    func move(move:Move) {
        
        guard IsMoveLegal(move) else {
            logger.error("move is not allowed")
            return
        }

        doCaptures(move)
        doMove(move)
        recreateBoardDict()
        moves += [move]
    }
    
    func getColorToMove() -> PieceColor {
        return colorToMove
    }
    
    func getPossibleMoves(forPeace:Figure) -> [Move] {
        guard let piece = figures.first(where: {$0==forPeace}) else {
            logger.error("Piece not found on the board")
            return []
        }
        let moves = piece.getPossibleMoves()
        return moves.filter({ IsMoveLegal($0) })
    }
    
    func getFigures() -> [Figure] {
        return figures
    }
    
    private func IsMoveLegal(_ target:Move) -> Bool {
        if !isMoveInBoard(target) {
            logger.warning("move would jump out of the board")
            return false
        }
        
        if !isMovePossible(target) {
            logger.warning("not possible")
            return false
        }
        
        if doesMovePutOwnKingInCheck(target) {
            logger.warning("move would set own king in check")
            return false
        }
        
        return true
    }
    
    private func doCaptures(_ move: Move) {
        let notSameFile = move.piece.getFile() != move.file
        if move.piece.getType() == PieceType.pawn && notSameFile && boardDict[move.row]?[move.file] == nil {
            captureFigureAt(row: move.piece.getRow(), file: move.file)
        } else {
            captureFigureAt(row: move.row, file: move.file)
        }
    }
    
    private func doMove(_ move: Move) {
        move.piece.move(row: move.row, file: move.file)
        if move.piece.getType() == PieceType.pawn && (move.row == 1 || move.row == 8) {
            // Todo: Promotion Choice
            figures.remove(at: figures.firstIndex(where: { $0 == move.piece })!)
            figures.append(Queen(color: move.piece.getColor(), row: move.row, file: move.file))
        }
        if move.piece.getType() == .king && move.type == .Castle {
            moveRookForCastling(move)
        }
        colorToMove = colorToMove == .black ? .white : .black
        logger.log("\(move.info())")
    }
    
    private func isMovePossible( _ move: Move) -> Bool {
        switch move.piece.getType() {
            case .pawn:
                return isPawnMove(move)
            case .king:
                return isKingMove(move)
            case .bishop, .knight, .rook, .queen:
                return isMove(move)
        }
    }
    
    private func captureFigureAt(row: Int, file: Int) {
        let figureAtTarget = boardDict[row]?[file];
        if figureAtTarget != nil {
            let index = figures.firstIndex(where: {f in f == figureAtTarget! })
            if index != nil {
                figures.remove(at: index!)
                logger.info("\(String(describing: figureAtTarget!.getColor())) \(String(describing:figureAtTarget!.getType())) at \(row):\(file) got captured")
            }
        }
    }
    
    private func moveRookForCastling(_ move: Move) {
        if move.file == King.LongCastlePosition {
            guard let rook = boardDict[move.piece.getRow()]?[1] else {
                logger.error("rook not found")
                return
            }
        
            rook.move(row: move.row, file: Rook.LongCastlePosition)
            
        } else if move.file == King.ShortCastlePosition {
            guard let rook = boardDict[move.piece.getRow()]?[8] else {
                logger.error("rook not found")
                return
            }
            rook.move(row: move.row, file: Rook.ShortCastlePosition)
        }
    }
    
    private func doesMovePutOwnKingInCheck(_ target:Move) -> Bool {
        
        let startRow = target.piece.getRow()
        let startFile = target.piece.getFile()
        target.piece.move(row: target.row, file: target.file)
        
        recreateBoardDict()
        
        guard let king = figures.first(where: { $0.getType() == .king && $0.getColor() == target.piece.getColor() }) else {
            logger.error("we dont have a king?")
            return false
        }
        let isKingInCheck = isFieldInCheck(king.getRow(), king.getFile())
        
        target.piece.move(row: startRow, file: startFile)
        
        recreateBoardDict()
        
        return isKingInCheck
    }
    
    private func isPawnMove(_ move: Move) -> Bool {

        let moveIsPossible = move.piece.getPossibleMoves().contains(where:{ $0 == move })
        let canMoveOnce = canPawnMoveOnce(move)
        let canMoveTwice = canPawnMoveTwice(move)
        let canCapture = canPawnCapture(move, lastMove: moves.last)
        
        return  moveIsPossible && (canMoveOnce || canMoveTwice || canCapture)
    }
    
    private func canPawnMoveOnce(_ move: Move) -> Bool {
        let noFileChange = move.file == move.piece.getFile()
        let targetSquareIsEmpty = boardDict[move.row]?[move.file] == nil
        return move.type == .Normal && noFileChange && targetSquareIsEmpty
    }
    
    private func canPawnMoveTwice(_ move: Move) -> Bool {
        let noFileChange = move.file == move.piece.getFile()
        let targetSquareIsEmpty = boardDict[move.row]?[move.file] == nil
        let squareBeforeStartIsEmpty = boardDict[move.piece.getColor() == PieceColor.white ? move.piece.getRow()+1 : move.piece.getRow()-1]?[move.piece.getFile()] == nil
        return move.type == .Double && !move.piece.hasMoved() && noFileChange && targetSquareIsEmpty && squareBeforeStartIsEmpty
    }
    
    private func canPawnCapture(_ move:Move, lastMove:Move?) -> Bool {
        
        let piece = move.piece
        let movedOnce = move.type != .Double
        let figureToCaptureOnLeft = boardDict[piece.getColor() == PieceColor.white ? piece.getRow()+1 : piece.getRow()-1]?[piece.getFile() - 1] != nil
        let figureToCaptureOnRight = boardDict[piece.getColor() == PieceColor.white ? piece.getRow()+1 : piece.getRow()-1]?[piece.getFile() + 1] != nil
        let canEnPassant = canEnPassant(move, lastMove: moves.last)
        return movedOnce && (figureToCaptureOnLeft || figureToCaptureOnRight || canEnPassant)
    }
    
    private func canEnPassant(_ move:Move, lastMove:Move?) -> Bool {
        guard let lastMove = lastMove else {
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

    
    private func isKingMove(_ move:Move) -> Bool {
        let isLegalMove =  isMove(move)
        let isCatlingInCheck = isCastlingInCheck(move)
        return isLegalMove && !isCatlingInCheck
    }
    
    private func isCastlingInCheck(_ move:Move) -> Bool {
        
        let isLongCastle = move.type == .Castle && move.file == King.LongCastlePosition
        
        let isKingStartingPositionInCheck = isFieldInCheck(move.piece.getRow(), move.piece.getFile())
        let isKingMovingThroughChek = isFieldInCheck(move.row, isLongCastle ? move.file + 1 : move.file - 1)
        let isKingLandingInCheck = isFieldInCheck(move.row, move.file)
        
        return isKingStartingPositionInCheck && isKingMovingThroughChek && isKingLandingInCheck
    }
    
    private func isFieldInCheck(_ row: Int, _ file: Int) -> Bool {
        guard figures.contains(where: { $0.getColor() != colorToMove && isMove(Move(row, file, piece: $0))}) else {
            return false
        }
        return true
    }
    
    private func isMove(_ move: Move) -> Bool {
        
        let possiblePeaceMoves = move.piece.getPossibleMoves()
        guard possiblePeaceMoves.contains(where:{$0 == move}) else { return false }
        
        guard let intersectingPiece = getIntersectingPiece(move) else { return true }
        
        return isCaptureablePiece(move, pieceToCapture: intersectingPiece)
        
    }
    
    private func isCaptureablePiece(_ move: Move, pieceToCapture: Figure?) -> Bool {
        return move.piece.getColor() != pieceToCapture!.getColor() && pieceToCapture!.getRow() == move.row && pieceToCapture!.getFile() == move.file
    }
    
    private func getIntersectingPiece(_ move: Move) -> Figure? {
        let deltaFile = abs(move.piece.getFile() - move.file)
        let deltaRow = abs(move.piece.getRow() - move.row)
        
        if deltaRow == 0 {
            return getIntersectingPieceOnRow(move)
        } else if deltaFile == 0 {
            return getIntersectingPieceOnFile(move)
        } else if deltaRow == deltaFile {
            return getIntersectingPieceOnDiagonal(move)
        } else if move.piece.getType() == .knight {
            return getIntersectingPieceForKnight(move)
        }
        return nil
    }
    
    private func getIntersectingPieceOnRow(_ move: Move) -> Figure? {
        for f in stride(from: move.piece.getFile(), to: move.file, by: move.piece.getFile() < move.file ? 1 : -1)  {
            let foundPiece = boardDict[move.piece.getRow()]?[f];
            if foundPiece != nil && foundPiece! != move.piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceOnFile(_ move: Move) -> Figure? {
        for r in stride(from: move.piece.getRow(), to: move.row, by: move.piece.getRow() < move.row ? 1 : -1) {
            let foundPiece = boardDict[r]?[move.piece.getFile()]
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
            let foundPiece = boardDict[move.piece.getRow()+(i*rowDir)]?[move.piece.getFile()+(i*fileDir)]
            if foundPiece != nil && foundPiece! != move.piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceForKnight(_ move: Move) -> Figure? {
        return boardDict[move.row]?[move.file]
    }
    
    private func isMoveInBoard(_ move:Move) -> Bool {
        return 1...8 ~= move.row && 1...8 ~= move.file
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
