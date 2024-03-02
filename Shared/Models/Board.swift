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
    private var enPassantIsPossible:Bool = false

    func move(figure: Figure, move:Move) {
        let move = figure.enrichMove(move: move) ?? move;

        if IsMoveLegal(piece: figure, target: move) {
            doCaptures(figure, move)
            doMove(figure, move)
            recreateFiguresCache()
            colorToMove = colorToMove == .black ? .white : .black
            moves += [move]
            logger.log("\(move.info())")
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
        if piece.color != colorToMove {
            logger.warning("wrong color")
            return false
        }
        
        if !isMoveInBoard(target) {
            logger.warning("not in board")
            return false
        }
        
        if !isMovePossible(target, forPiece: piece) {
            logger.warning("not possible")
            return false
        }
        
        return true
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
        enPassantIsPossible = figure.type == PieceType.pawn && abs(move.row - figure.row) == 2
        figure.move(to: move)
        if figure.type == PieceType.pawn && (move.row == 1 || move.row == 8) {
            // Todo: Promotion Choice
            let promotedPiece = PieceType.queen
            figures.remove(at: figures.firstIndex(where: { $0 == figure })!)
            figures.append(Figure(type: promotedPiece, color: figure.color, row: move.row, file: move.file))
        }
        if figure.type == .king && move.type == .Castle {
            if move.file == 3 {
                guard let rook = figuresDict[figure.row]?[1] else {
                    logger.error("rook not found")
                    return
                }
                doMove(rook, Move(move.row, 4, piece: .rook, type: .Castle))
                
            } else if move.file == 7 {
                guard let rook = figuresDict[figure.row]?[8] else {
                    logger.error("rook not found")
                    return
                }
                doMove(rook, Move(move.row, 6, piece: .rook, type: .Castle))
                
            }
            
        }
    }
    
    private func captureFigureAt(row: Int, file: Int) {
        let figureAtTarget = figuresDict[row]?[file];
        if figureAtTarget != nil {
            let index = figures.firstIndex(where: {f in f == figureAtTarget! })
            if index != nil {
                figures.remove(at: index!)
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
        let movedOnce = abs(move.row - forPiece.row) == 1
        let movedTwice = abs(move.row - forPiece.row) == 2
        let lastMoveToLeft = lastMove?.row == forPiece.row && lastMove!.file - forPiece.file == -1
        let lastMoveToRight = lastMove?.row == forPiece.row && lastMove!.file - forPiece.file == 1
        let figureToCaptureOnLeft = figuresDict[forPiece.color == PieceColor.white ? forPiece.row+1 : forPiece.row-1]?[forPiece.file - 1] != nil
        let figureToCaptureOnRight = figuresDict[forPiece.color == PieceColor.white ? forPiece.row+1 : forPiece.row-1]?[forPiece.file + 1] != nil
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
        let isKingMovingThroughChek = isFieldInCheck(move.row, isLongCastle ? move.file + 1 : move.file - 1)
        let isKingLandingInCheck = isFieldInCheck(move.row, move.file)
        
        return isLegalMove && !isKingLandingInCheck && !isKingMovingThroughChek
    }
    
    private func isFieldInCheck(_ row: Int, _ file: Int) -> Bool {
        // Todo: determine whether king is in check
        return false
    }
    
    private func isLegalMove(_ piece: Figure, _ move: Move) -> Bool {
        let intersectingPiece = getIntersectingPiece(piece, move)
        if intersectingPiece != nil {
            return piece.color != intersectingPiece!.color && intersectingPiece!.row == move.row && intersectingPiece!.file == move.file
        }
        
        let possiblePeaceMoves = piece.getPossibleMoves()
        return possiblePeaceMoves.contains(where:{$0 == move})
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
        let start = min(piece.file, move.file)
        let stop = max(piece.file, move.file)
        for f in start...stop {
            let foundPiece = figuresDict[piece.row]?[f];
            if foundPiece != nil && foundPiece! != piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceOnFile(_ piece: Figure, _ move: Move) -> Figure? {
        let start = min(piece.row, move.row)
        let stop = max(piece.row, move.row)
        for r in start...stop {
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
