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
    
    private var figuresDict:[Int:[Int:Figure]] = [:]
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

        if IsMoveLegal(piece: figure, target: move) {
            doCaptures(figure, move)
            doMove(figure, move)
            recreateFiguresCache()
            moves += [move]
        }
    }
    
    func getLegalMoves() -> [Move] {
        if focus != nil {
            let possibleMoves = focus!.getPossibleMoves()
            return possibleMoves.filter({ move in IsMoveLegal(piece: focus!, target: move)})
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
        recreateFiguresCache()
    }
    
    private func IsMoveLegal(piece: Figure, target:Move) -> Bool {

        if !isMoveInBoard(target) {
            logger.warning("move would jump out of the board")
            return false
        }
        
        if !isMovePossible(target, forPiece: piece) {
            logger.warning("not possible")
            return false
        }
        
        if doesMovePutOwnKingInCheck(target, forPiece: piece) {
            logger.warning("move would set own king in check")
            return false
        }
        
        return true
    }
    
    private func doesMovePutOwnKingInCheck(_ target:Move, forPiece:Figure) -> Bool {
        let startRow = forPiece.row
        let startFile = forPiece.file
        forPiece.move(to: target)
        recreateFiguresCache()
        guard let king = figures.first(where: { $0.type == .king && $0.color == forPiece.color }) else {
            logger.error("we dont have a king?")
            return false
        }
        let isKingInCheck = isFieldInCheck(king.row, king.file)
        
        forPiece.move(to: Move(startRow, startFile, piece: forPiece.type))
        recreateFiguresCache()
        
        return isKingInCheck
    }
    
    func doCaptures(_ figure: Figure, _ move: Move) {
        let notSameFile = figure.file != move.file
        if figure.type == PieceType.pawn && notSameFile && figuresDict[move.row]?[move.file] == nil {
            captureFigureAt(row: figure.row, file: move.file)
        } else {
            captureFigureAt(row: move.row, file: move.file)
        }
    }
    
    func doMove(_ figure: Figure, _ move: Move) {
        figure.move(to: move)
        if figure.type == PieceType.pawn && (move.row == 1 || move.row == 8) {
            // Todo: Promotion Choice
            let promotedPiece = PieceType.queen
            figures.remove(at: figures.firstIndex(where: { $0 == figure })!)
            figures.append(Figure(type: promotedPiece, color: figure.color, row: move.row, file: move.file))
        }
        if figure.type == .king && move.type == .Castle {
            moveRookForCastling(move, figure)
        }
        colorToMove = colorToMove == .black ? .white : .black
        logger.log("\(move.info())")
    }
    
    private func captureFigureAt(row: Int, file: Int) {
        let figureAtTarget = figuresDict[row]?[file];
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
    
    private func isMovePossible( _ move: Move, forPiece: Figure) -> Bool {
        switch forPiece.type {
        case .pawn:
            return isLegalPawnMove(forPiece, move)
        case .king:
            return islegalKingMove(forPiece, move)
        case .bishop, .knight, .rook, .queen:
            return isLegalMove(forPiece, move)
        }
    }
    
    private func isLegalPawnMove(_ forPiece: Figure, _ move: Move) -> Bool {
        let lastMove = moves.last
        
        let moveIsPossible = forPiece.getPossibleMoves().contains(where:{ $0 == move })
        let targetSquareIsEmpty = figuresDict[move.row]?[move.file] == nil
        let squareBeforeStartIsEmpty = figuresDict[forPiece.color == PieceColor.white ? forPiece.row+1 : forPiece.row-1]?[forPiece.file] == nil
        let noFileChange = move.file == forPiece.file
        let movedOnce = move.type != .Double
        let movedTwice = move.type == .Double
        let lastMoveToLeft = lastMove?.row == forPiece.row && lastMove!.file - forPiece.file == -1
        let lastMoveToRight = lastMove?.row == forPiece.row && lastMove!.file - forPiece.file == 1
        let figureToCaptureOnLeft = figuresDict[forPiece.color == PieceColor.white ? forPiece.row+1 : forPiece.row-1]?[forPiece.file - 1] != nil
        let figureToCaptureOnRight = figuresDict[forPiece.color == PieceColor.white ? forPiece.row+1 : forPiece.row-1]?[forPiece.file + 1] != nil
        let enPassantIsPossible = lastMove != nil && lastMove?.piece == .pawn && lastMove?.type == .Double
        let canEnPassantToLeft = movedOnce && enPassantIsPossible && lastMoveToLeft && move.file - forPiece.file == -1
        let canEnPassantToRight = movedOnce && enPassantIsPossible && lastMoveToRight && move.file - forPiece.file == 1

        let canMoveOnce = movedOnce && noFileChange && targetSquareIsEmpty
        let canMoveTwice = !forPiece.moved && movedTwice && noFileChange && targetSquareIsEmpty && squareBeforeStartIsEmpty
        let canCapture = movedOnce && (figureToCaptureOnLeft || figureToCaptureOnRight || canEnPassantToLeft || canEnPassantToRight)
        
        return  moveIsPossible && (canMoveOnce || canMoveTwice || canCapture)
    }
    
    private func islegalKingMove(_ piece:Figure, _ move:Move) -> Bool {
        let isLegalMove =  isLegalMove(piece, move)
        
        let isCastle = move.type == .Castle
        let isLongCastle = isCastle && move.file == Figure.longCastleKingPosition
        let isKingStartingPositionInCheck = isFieldInCheck(piece.row, piece.file)
        let isKingMovingThroughChek = isFieldInCheck(move.row, isLongCastle ? move.file + 1 : move.file - 1)
        let isKingLandingInCheck = isFieldInCheck(move.row, move.file)
        
        return isLegalMove && !isKingStartingPositionInCheck && !isKingLandingInCheck && !isKingMovingThroughChek
    }
    
    private func isFieldInCheck(_ row: Int, _ file: Int) -> Bool {
        guard let figure = figures.first(where: { $0.color != colorToMove && isLegalMove($0, Move(row, file, piece: $0.type))}) else {
            return false
        }
        
        logger.info("(\(row):\(file)) is in check by \(String(describing: figure.type)) at \(figure.row):\(figure.file)")
        return true
    }
    
    private func isLegalMove(_ piece: Figure, _ move: Move) -> Bool {
        
        let possiblePeaceMoves = piece.getPossibleMoves()
        guard possiblePeaceMoves.contains(where:{$0 == move}) else { return false }
        
        guard let intersectingPiece = getIntersectingPiece(piece, move) else { return true }
        
        return isCaptureablePiece(piece, withMove: move, intersectingPiece: intersectingPiece)
        
    }
    
    private func isCaptureablePiece(_ piece: Figure,  withMove: Move, intersectingPiece: Figure?) -> Bool {
        return piece.color != intersectingPiece!.color && intersectingPiece!.row == withMove.row && intersectingPiece!.file == withMove.file
    }
    
    private func moveRookForCastling(_ move: Move, _ figure: Figure) {
        if move.file == Figure.longCastleKingPosition {
            guard let rook = figuresDict[figure.row]?[1] else {
                logger.error("rook not found")
                return
            }
        
            rook.move(to: Move(move.row, 4, piece: .rook, type: .Castle))
            
        } else if move.file == Figure.shortCastleKingPosition {
            guard let rook = figuresDict[figure.row]?[8] else {
                logger.error("rook not found")
                return
            }
            rook.move(to: Move(move.row, 6, piece: .rook, type: .Castle))
        }
    }
    
    private func getIntersectingPiece(_ piece: Figure, _ move: Move) -> Figure? {
        let deltaFile = abs(piece.file - move.file)
        let deltaRow = abs(piece.row - move.row)
        
        if deltaRow == 0 {
            return getIntersectingPieceOnRow(piece, move)
        } else if deltaFile == 0 {
            return getIntersectingPieceOnFile(piece, move)
        } else if deltaRow == deltaFile {
            return getIntersectingPieceOnDiagonal(move, piece)
        } else if piece.type == .knight {
            return getIntersectingPieceForKnight(move, piece)
        }
        return nil
    }
    
    private func getIntersectingPieceOnRow(_ piece: Figure, _ move: Move) -> Figure? {
        for f in stride(from: piece.file, to: move.file, by: piece.file < move.file ? 1 : -1)  {
            let foundPiece = figuresDict[piece.row]?[f];
            if foundPiece != nil && foundPiece! != piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceOnFile(_ piece: Figure, _ move: Move) -> Figure? {
        for r in stride(from: piece.row, to: move.row, by: piece.row < move.row ? 1 : -1) {
            let foundPiece = figuresDict[r]?[piece.file]
            if foundPiece != nil && foundPiece! != piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceOnDiagonal(_ move: Move, _ piece: Figure) -> Figure? {
        let rowDir = min(max(move.row - piece.row, -1), 1)
        let fileDir = min(max(move.file - piece.file, -1), 1)
        let delta = abs(piece.file - move.file)
        for i in 1...delta {
            let foundPiece = figuresDict[piece.row+(i*rowDir)]?[piece.file+(i*fileDir)]
            if foundPiece != nil && foundPiece! != piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceForKnight(_ move: Move, _ piece: Figure) -> Figure? {
        return figuresDict[move.row]?[move.file]
    }
    
    private func recreateFiguresCache(){
        var dict:[Int:[Int:Figure]] = [:]
        for f in figures {
            if dict[f.row] == nil {
                dict[f.row] = [:]
            }
            dict[f.row]![f.file] = f
        }
        figuresDict = dict
    }
}
