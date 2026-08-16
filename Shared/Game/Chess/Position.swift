import Foundation
import os

class Position {
    private static let logger = Log.logger("Position")

    private let cache:[Int:[Int:any ChessFigure]]
    let colorToMove:PieceColor
    let enPassantTarget:Field?
    let canWhiteCastleKingside:Bool
    let canWhiteCastleQueenside:Bool
    let canBlackCastleKingside:Bool
    let canBlackCastleQueenside:Bool
    let halfmoveClock:Int
    let moveClock:Int
    
    var figures:[any ChessFigure] { cache.flatMap({ $1.values }) }
    
    init(
        _ figures: [any ChessFigure],
        colorToMove:PieceColor,
        enPassantTarget:Field?,
        whiteCanCastleKingside:Bool,
        whiteCanCastleQueenside:Bool,
        blackCanCastleKingside:Bool,
        blackCanCastleQueenside:Bool,
        moveClock:Int,
        halfmoveClock:Int
    ) {
        self.cache = Position.createCacheDict(figures) ?? [:]
        self.colorToMove = colorToMove
        self.enPassantTarget = enPassantTarget
        self.canWhiteCastleKingside = whiteCanCastleKingside
        self.canWhiteCastleQueenside = whiteCanCastleQueenside
        self.canBlackCastleKingside = blackCanCastleKingside
        self.canBlackCastleQueenside = blackCanCastleQueenside
        self.moveClock = moveClock
        self.halfmoveClock = halfmoveClock
    }
    
    func get(atRow:Int, atFile:Int) -> (any ChessFigure)? {
        return cache[atRow]?[atFile]
    }
    
    func isEmpty(atRow:Int, atFile:Int) -> Bool {
        return get(atRow: atRow, atFile: atFile) == nil
    }
    
    func isNotEmpty(atRow:Int, atFile:Int) -> Bool {
        return isEmpty(atRow: atRow, atFile: atFile) == false
    }
    
    func getNextPiece(_ move: Move) -> (any ChessFigure)? {
        let deltaFile = abs(move.piece.file - move.file)
        let deltaRow = abs(move.piece.row - move.row)
        
        if deltaRow == 0 {
            return getNextPieceOnRow(from: move.piece.field, to: move.field)
        } else if deltaFile == 0 {
            return getNextPieceOnFile(from: move.piece.field, to: move.field)
        } else if deltaRow == deltaFile {
            return getNextPieceOnDiagonal(from: move.piece.field, to: move.field)
        }
        return get(atRow: move.row, atFile: move.file)
    }
    
    func isEnPassant(_ move:Move) -> Bool {
        canEnPassant(move) && isEmpty(atRow: move.row, atFile: move.file) && enPassantTarget == move.field
    }
    
    func canEnPassant(_ move:Move) -> Bool {
        guard let target = enPassantTarget else { return false }
        return move.field == target
    }
    
    func getHash() -> Int {
        var hasher = Hasher()
        for fig in figures.sorted(by: { $0.row > $1.row }).sorted(by: { $0.file > $1.file }) {
            hasher.combine(fig)
        }
        hasher.combine(enPassantTarget)
        return hasher.finalize()
    }
    
    func applying(_ move: Move) -> Position {
        var figures = figures
        let capturedPiece = applyCapture(&figures, move: move)
        applyMovement(&figures, move: move, capturedPiece: capturedPiece)
        if CastlingRules.isCastlingMove(move) { applyCastlingRook(&figures, move: move) }
        if isPawnPromotion(move) { applyPromotion(&figures, move: move) }
        return PositionFactory.create(self, afterMove: move, figures: figures, capturedPiece: capturedPiece)
    }
    
    private func applyCapture(_ figures: inout [any ChessFigure], move: Move) -> (any ChessFigure)? {
        let capturedPiece = get(atRow: move.row, atFile: move.file)
        figures.removeAll(where: { $0.equals(move.piece) || capturedPiece?.equals($0) == true })
        return capturedPiece
    }
    
    private func applyMovement(_ figures: inout [any ChessFigure], move: Move, capturedPiece: (any ChessFigure)?) {
        if isEnPassant(move) {
            figures.removeAll(where: { $0.row == move.piece.row && $0.file == move.file })
        }
        figures.append(Figure.create(type: move.piece.type, color: move.piece.color, row: move.row, file: move.file, moved: true))
    }
    
    private func applyCastlingRook(_ figures: inout [any ChessFigure], move: Move) {
        guard let (fromFile, toFile) = CastlingRules.castlingRookMove(for: move) else { return }
        let rookRow  = move.piece.row
        let rookColor = move.piece.color
        figures.removeAll(where: { $0.type == .rook && $0.color == rookColor && $0.row == rookRow && $0.file == fromFile })
        figures.append(Figure.create(type: .rook, color: rookColor, row: rookRow, file: toFile, moved: true))
    }
    
    private func applyPromotion(_ figures: inout [any ChessFigure], move: Move) {
        figures.removeAll(where: { $0.type == .pawn && $0.color == move.piece.color && $0.row == move.row && $0.file == move.file })
        figures.append(Figure.create(type: move.promoteTo, color: move.piece.color, row: move.row, file: move.file))
    }
    
    private func isPawnPromotion(_ move: Move) -> Bool {
        return move.piece.type == .pawn && pawnHasReachedEndOfTheBoard(move)
    }
    
    private func getNextPieceOnRow(from:Field, to:Field) -> (any ChessFigure)? {
        let direction = from.file < to.file ? 1 : -1
        for f in stride(from: from.file + direction, to: to.file, by: direction) {
            if let piece = get(atRow: from.row, atFile: f) { return piece }
        }
        return get(atRow: to.row, atFile: to.file)
    }
    
    private func getNextPieceOnFile(from:Field, to:Field) -> (any ChessFigure)? {
        let direction = from.row < to.row ? 1 : -1
        for r in stride(from: from.row + direction, to: to.row, by: direction) {
            if let piece = get(atRow: r, atFile: from.file) { return piece }
        }
        return get(atRow: to.row, atFile: to.file)
    }
    
    private func getNextPieceOnDiagonal(from:Field, to:Field) -> (any ChessFigure)? {
        let rowDir = min(max(to.row - from.row, -1), 1)
        let fileDir = min(max(to.file - from.file, -1), 1)
        let delta = abs(from.file - to.file)
        if delta > 1 {
            for i in 1...delta {
                if let piece = get(atRow: from.row + i * rowDir, atFile: from.file + i * fileDir) { return piece }
            }
        }
        return get(atRow: to.row, atFile: to.file)
    }
    
    private func pawnHasReachedEndOfTheBoard(_ move:Move) -> Bool {
        return (move.piece.color == .white && move.row == 8) || (move.piece.color == .black && move.row == 1)
    }
    
    private static func createCacheDict(_ figures: [any ChessFigure]) -> [Int : [Int : any ChessFigure]]? {
        var dict:[Int:[Int:any ChessFigure]] = [:]
        for figure in figures {
            if dict[figure.row] == nil {
                dict[figure.row] = [:]
            }
            guard dict[figure.row]?[figure.file] == nil else {
                Position.logger.error("could not set \(figure.info()) because field is occupied by \(dict[figure.row]?[figure.file]?.info() ?? "")")
                return nil
            }
            dict[figure.row]![figure.file] = figure
        }
        return dict
    }
}
