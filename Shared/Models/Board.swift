//
//  BoardViewModel.swift
//  SwiftChess
//
//  Created by Jan Fässler on 13.12.21.
//
import SwiftUI
import os

class Board : ObservableObject {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "board")
    
    @Published var figures:[Figure] = []
    @Published var focus:Figure?
    
    private var boardDict:[Int:[Int:Figure]] = [:]
    private var colorToMove:PieceColor = .white
    private var moves: [Move] = []

    func move(figure: Figure, deltaRow:Int, deltaFile:Int) {
        
        guard figure.color == colorToMove else {
            logger.error("other player has to move first")
            return
        }
        
        guard let move = figure.getMove(deltaRow: deltaRow, deltaFile: deltaFile) else {
            logger.error("no possible move found")
            return
        }

        if IsMoveLegal(move) {
            doCaptures(figure, move)
            doMove(figure, move)
            recreateBoardDict()
            moves += [move]
        }
    }
    
    func getLegalMoves() -> [Move] {
        if focus != nil {
            let possibleMoves = focus!.getPossibleMoves()
            return possibleMoves.filter({ IsMoveLegal($0) })
        }
        return []
    }
    
    func setFocus(_ fig: Figure) {
        focus = fig
    }
    
    func clearFocus() {
        if focus != nil {
            focus = nil
        }
    }
    
    func addFigures() {
        let pos = Fen.loadStartingPosition()
        figures.append(contentsOf: pos.figures)
        recreateBoardDict()
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
    
    private func doesMovePutOwnKingInCheck(_ target:Move) -> Bool {
        
        let startRow = target.piece.row
        let startFile = target.piece.file
        target.piece.move(to: target)
        
        recreateBoardDict()
        
        guard let king = figures.first(where: { $0.type == .king && $0.color == target.piece.color }) else {
            logger.error("we dont have a king?")
            return false
        }
        let isKingInCheck = isFieldInCheck(king.row, king.file)
        
        target.piece.move(to: Move(startRow, startFile, piece: target.piece, type: .Revert))
        recreateBoardDict()
        
        return isKingInCheck
    }
    
    func doCaptures(_ figure: Figure, _ move: Move) {
        let notSameFile = figure.file != move.file
        if figure.type == PieceType.pawn && notSameFile && boardDict[move.row]?[move.file] == nil {
            captureFigureAt(row: figure.row, file: move.file)
        } else {
            captureFigureAt(row: move.row, file: move.file)
        }
    }
    
    func doMove(_ figure: Figure, _ move: Move) {
        figure.move(to: move)
        if figure.type == PieceType.pawn && (move.row == 1 || move.row == 8) {
            // Todo: Promotion Choice
            figures.remove(at: figures.firstIndex(where: { $0 == figure })!)
            figures.append(Queen(color: figure.color, row: move.row, file: move.file))
        }
        if figure.type == .king && move.type == .Castle {
            moveRookForCastling(move, figure)
        }
        colorToMove = colorToMove == .black ? .white : .black
        logger.log("\(move.info())")
    }
    
    private func captureFigureAt(row: Int, file: Int) {
        let figureAtTarget = boardDict[row]?[file];
        if figureAtTarget != nil {
            let index = figures.firstIndex(where: {f in f == figureAtTarget! })
            if index != nil {
                figures.remove(at: index!)
                logger.info("\(String(describing: figureAtTarget!.color)) \(String(describing:figureAtTarget!.type)) at \(row):\(file) got captured")
            }
        }
    }
    
    private func isMoveInBoard(_ move:Move) -> Bool {
        return 1...8 ~= move.row && 1...8 ~= move.file
    }
    
    private func isMovePossible( _ move: Move) -> Bool {
        switch move.piece.type {
            case .pawn:
                return isLegalPawnMove(move)
            case .king:
                return islegalKingMove(move)
            case .bishop, .knight, .rook, .queen:
                return isLegalMove(move)
        }
    }
    
    private func isLegalPawnMove(_ move: Move) -> Bool {
        
        let piece = move.piece

        let moveIsPossible = piece.getPossibleMoves().contains(where:{ $0 == move })
        
        let noFileChange = move.file == piece.file
        let targetSquareIsEmpty = boardDict[move.row]?[move.file] == nil
        let squareBeforeStartIsEmpty = boardDict[piece.color == PieceColor.white ? piece.row+1 : piece.row-1]?[piece.file] == nil

        let canMoveOnce = move.type == .Normal && noFileChange && targetSquareIsEmpty
        let canMoveTwice = move.type == .Double && !piece.moved && noFileChange && targetSquareIsEmpty && squareBeforeStartIsEmpty
        let canCapture = canPawnCapture(move, lastMove: moves.last)
        
        return  moveIsPossible && (canMoveOnce || canMoveTwice || canCapture)
    }
    
    private func canPawnCapture(_ move:Move, lastMove:Move?) -> Bool {
        
        let piece = move.piece
        let movedOnce = move.type != .Double
        let figureToCaptureOnLeft = boardDict[piece.color == PieceColor.white ? piece.row+1 : piece.row-1]?[piece.file - 1] != nil
        let figureToCaptureOnRight = boardDict[piece.color == PieceColor.white ? piece.row+1 : piece.row-1]?[piece.file + 1] != nil
        let canEnPassant = canEnPassant(move, lastMove: moves.last)
        return movedOnce && (figureToCaptureOnLeft || figureToCaptureOnRight || canEnPassant)
    }
    
    private func canEnPassant(_ move:Move, lastMove:Move?) -> Bool {
        guard let lastMove = lastMove else {
            return false
        }
        
        let piece = move.piece
        let movedOnce = move.type != .Double
        let lastMoveToLeft = lastMove.row == piece.row && lastMove.file - piece.file == -1
        let lastMoveToRight = lastMove.row == piece.row && lastMove.file - piece.file == 1
        let enPassantIsPossible = lastMove.piece.type == .pawn && lastMove.type == .Double
        let canEnPassantToLeft = movedOnce && enPassantIsPossible && lastMoveToLeft && move.file - piece.file == -1
        let canEnPassantToRight = movedOnce && enPassantIsPossible && lastMoveToRight && move.file - piece.file == 1
        return canEnPassantToLeft || canEnPassantToRight
    }

    
    private func islegalKingMove(_ move:Move) -> Bool {
        let isLegalMove =  isLegalMove(move)
        let isCatlingInCheck = isCastlingInCheck(move)
        return isLegalMove && !isCatlingInCheck
    }
    
    private func isCastlingInCheck(_ move:Move) -> Bool {
        
        let isLongCastle = move.type == .Castle && move.file == Figure.longCastleKingPosition
        
        let isKingStartingPositionInCheck = isFieldInCheck(move.piece.row, move.piece.file)
        let isKingMovingThroughChek = isFieldInCheck(move.row, isLongCastle ? move.file + 1 : move.file - 1)
        let isKingLandingInCheck = isFieldInCheck(move.row, move.file)
        
        return isKingStartingPositionInCheck && isKingMovingThroughChek && isKingLandingInCheck
    }
    
    private func isFieldInCheck(_ row: Int, _ file: Int) -> Bool {
        guard figures.contains(where: { $0.color != colorToMove && isLegalMove(Move(row, file, piece: $0))}) else {
            return false
        }
        return true
    }
    
    private func isLegalMove(_ move: Move) -> Bool {
        
        let possiblePeaceMoves = move.piece.getPossibleMoves()
        guard possiblePeaceMoves.contains(where:{$0 == move}) else { return false }
        
        guard let intersectingPiece = getIntersectingPiece(move) else { return true }
        
        return isCaptureablePiece(move, pieceToCapture: intersectingPiece)
        
    }
    
    private func isCaptureablePiece(_ move: Move, pieceToCapture: Figure?) -> Bool {
        return move.piece.color != pieceToCapture!.color && pieceToCapture!.row == move.row && pieceToCapture!.file == move.file
    }
    
    private func moveRookForCastling(_ move: Move, _ figure: Figure) {
        if move.file == Figure.longCastleKingPosition {
            guard let rook = boardDict[figure.row]?[1] else {
                logger.error("rook not found")
                return
            }
        
            rook.move(to: Move(move.row, 4, piece: rook, type: .Castle))
            
        } else if move.file == Figure.shortCastleKingPosition {
            guard let rook = boardDict[figure.row]?[8] else {
                logger.error("rook not found")
                return
            }
            rook.move(to: Move(move.row, 6, piece: rook, type: .Castle))
        }
    }
    
    private func getIntersectingPiece(_ move: Move) -> Figure? {
        let deltaFile = abs(move.piece.file - move.file)
        let deltaRow = abs(move.piece.row - move.row)
        
        if deltaRow == 0 {
            return getIntersectingPieceOnRow(move)
        } else if deltaFile == 0 {
            return getIntersectingPieceOnFile(move)
        } else if deltaRow == deltaFile {
            return getIntersectingPieceOnDiagonal(move)
        } else if move.piece.type == .knight {
            return getIntersectingPieceForKnight(move)
        }
        return nil
    }
    
    private func getIntersectingPieceOnRow(_ move: Move) -> Figure? {
        for f in stride(from: move.piece.file, to: move.file, by: move.piece.file < move.file ? 1 : -1)  {
            let foundPiece = boardDict[move.piece.row]?[f];
            if foundPiece != nil && foundPiece! != move.piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceOnFile(_ move: Move) -> Figure? {
        for r in stride(from: move.piece.row, to: move.row, by: move.piece.row < move.row ? 1 : -1) {
            let foundPiece = boardDict[r]?[move.piece.file]
            if foundPiece != nil && foundPiece! != move.piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceOnDiagonal(_ move: Move) -> Figure? {
        let rowDir = min(max(move.row - move.piece.row, -1), 1)
        let fileDir = min(max(move.file - move.piece.file, -1), 1)
        let delta = abs(move.piece.file - move.file)
        for i in 1...delta {
            let foundPiece = boardDict[move.piece.row+(i*rowDir)]?[move.piece.file+(i*fileDir)]
            if foundPiece != nil && foundPiece! != move.piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceForKnight(_ move: Move) -> Figure? {
        return boardDict[move.row]?[move.file]
    }
    
    private func recreateBoardDict(){
        var dict:[Int:[Int:Figure]] = [:]
        for f in figures {
            if dict[f.row] == nil {
                dict[f.row] = [:]
            }
            dict[f.row]![f.file] = f
        }
        boardDict = dict
    }
}
