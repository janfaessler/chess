import Foundation
import os

class Position {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Position")

    private var cache:[Int:[Int:any ChessFigure]]
    private let colorToMove:PieceColor
    private let enPassantTarget:Field?
    private let whiteCanCastleKingside:Bool
    private let whiteCanCastleQueenside:Bool
    private let blackCanCastleKingside:Bool
    private let blackCanCastleQueenside:Bool
    private let halfmoveClock:Int
    private let moveClock:Int
    
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
        self.whiteCanCastleKingside = whiteCanCastleKingside
        self.whiteCanCastleQueenside = whiteCanCastleQueenside
        self.blackCanCastleKingside = blackCanCastleKingside
        self.blackCanCastleQueenside = blackCanCastleQueenside
        self.moveClock = moveClock
        self.halfmoveClock = halfmoveClock
    }
    
    func get(atRow:Int, atFile:Int) -> (any ChessFigure)? {
        return cache[atRow]?[atFile]
    }
    
    func clearField(atRow:Int, atFile:Int) {
        cache[atRow]?[atFile] = nil
    }
    
    func set(_ figure:any ChessFigure) {
        if cache[figure.getRow()] == nil {
            cache[figure.getRow()] = [:]
        }
        cache[figure.getRow()]![figure.getFile()] = figure
    }
    
    func isEmpty(atRow:Int, atFile:Int) -> Bool {
        return get(atRow: atRow, atFile: atFile) == nil
    }
    
    func isNotEmpty(atRow:Int, atFile:Int) -> Bool {
        return isEmpty(atRow: atRow, atFile: atFile) == false
    }
    
    func getColorToMove() -> PieceColor {
        return colorToMove
    }
    
    func getEnPassantTarget() -> Field? {
        return enPassantTarget
    }
    
    func canWhiteCastleKingside() -> Bool {
        return whiteCanCastleKingside
    }
    
    func canWhiteCastleQueenside() -> Bool {
        return whiteCanCastleQueenside
    }
    
    func canBlackCastleKingside() -> Bool {
        return blackCanCastleKingside
    }
    
    func canBlackCastleQueenside() -> Bool {
        return blackCanCastleQueenside
    }
    
    func getMoveClock() -> Int {
        return moveClock
    }

    func getHalfmoveClock() -> Int {
        return halfmoveClock
    }

    func getFigures() -> [any ChessFigure] {
        return cache.flatMap({ $1.values })
    }
    
    func getNextPiece(_ move: Move) -> (any ChessFigure)? {
        let deltaFile = abs(move.piece.getFile() - move.file)
        let deltaRow = abs(move.piece.getRow() - move.row)
        
        if deltaRow == 0 {
            return getNextPieceOnRow(from: move.piece.getField(), to: move.getField())
        } else if deltaFile == 0 {
            return getNextPieceOnFile(from: move.piece.getField(), to: move.getField())
        } else if deltaRow == deltaFile {
            return getNextPieceOnDiagonal(from: move.piece.getField(), to: move.getField())
        }
        return get(atRow: move.row, atFile: move.file)
    }
    
    func isCheck(_ move: Move) -> Bool {
        guard let opponentKing = getFigures().first(where: { $0.getType() == .king && $0.getColor() != move.piece.getColor() }) else { return false }
        let newPosition = applying(move)
        return newPosition.isFieldInCheck(opponentKing.getRow(), opponentKing.getFile())
    }
    
    func isFieldInCheck(_ row: Int, _ file: Int) -> Bool {
        let figures = getFigures()
        return figures.contains(where: {
            if $0.getColor() == colorToMove { return false }
            return $0.isMovePossible(Move(row, file, piece: $0), position: self)
        })
    }
    
    func isCheckMate(_ move:Move) -> Bool {
        let newPosition = applying(move)
        return !newPosition.playerHasLegalMove() && newPosition.isKingInCheck()
    }
    
    func isLegalMove(_ target:Move) -> Bool {
        guard isMoveInBoard(target) else { return false }
        guard target.piece.isMovePossible(target, position: self) else { return false }
        guard !doesMovePutOwnKingInCheck(target) else { return false }
        return true
    }
    
    func playerHasLegalMove() -> Bool {
        let figuresOfCurrentPlayer = getFigures().filter({ $0.getColor() == colorToMove })
        return figuresOfCurrentPlayer.contains(where: { fig in fig.getPossibleMoves().contains(where: { move in isLegalMove(move) }) })
    }
    
    func isKingInCheck() -> Bool {
        guard let king = getFigures().first(where: { $0.getType() == .king && $0.getColor() == getColorToMove() }) else { return false }
        return isFieldInCheck(king.getRow(), king.getFile())
    }
    
    func isEnPassant(_ move:Move) -> Bool {
        canEnPassant(move) && isEmpty(atRow: move.row, atFile: move.file) && enPassantTarget == move.getField()
    }
    
    func canEnPassant(_ move:Move) -> Bool {
        guard let target = getEnPassantTarget() else { return false }
        return move.getField() == target
    }
    
    func getHash() -> Int {
        var hasher = Hasher()
        for fig in getFigures().sorted(by: { $0.getRow() > $1.getRow() }).sorted(by: { $0.getFile() > $1.getFile() }) {
            hasher.combine(fig)
        }
        hasher.combine(enPassantTarget)
        return hasher.finalize()
    }
    
    func applying(_ move: Move) -> Position {
        var figures = getFigures()
        let capturedPiece = applyCapture(&figures, move: move)
        applyMovement(&figures, move: move, capturedPiece: capturedPiece)
        if CastlingRules.isCastlingMove(move) { applyCastlingRook(&figures, move: move) }
        if isPawnPromotion(move) { applyPromotion(&figures, move: move) }
        return PositionFactory.create(self, afterMove: move, figures: figures, capturedPiece: capturedPiece)
    }
    
    private func applyCapture(_ figures: inout [any ChessFigure], move: Move) -> (any ChessFigure)? {
    
        let capturedPiece = get(atRow: move.getRow(), atFile: move.getFile())
        figures.removeAll(where: { $0.equals(move.getPiece()) || capturedPiece?.equals($0) == true })
        return capturedPiece
    }
    
    private func applyMovement(_ figures: inout [any ChessFigure], move: Move, capturedPiece: (any ChessFigure)?) {
        if isEnPassant(move) {
            figures.removeAll(where: { $0.getRow() == move.piece.getRow() && $0.getFile() == move.file })
        }
        figures.append(Figure.create(type: move.piece.getType(), color: move.piece.getColor(), row: move.getRow(), file: move.file, moved: true))
    }
    
    private func applyCastlingRook(_ figures: inout [any ChessFigure], move: Move) {
        guard let (fromFile, toFile) = CastlingRules.castlingRookMove(for: move) else { return }
        let rookRow  = move.piece.getRow()
        let rookColor = move.piece.getColor()
        figures.removeAll(where: { $0.getType() == .rook && $0.getColor() == rookColor && $0.getRow() == rookRow && $0.getFile() == fromFile })
        figures.append(Figure.create(type: .rook, color: rookColor, row: rookRow, file: toFile, moved: true))
    }
    
    private func applyPromotion(_ figures: inout [any ChessFigure], move: Move) {
        figures.removeAll(where: { $0.getType() == .pawn && $0.getColor() == move.piece.getColor() && $0.getRow() == move.getRow() && $0.getFile() == move.getFile() })
        figures.append(Figure.create(type: move.promoteTo, color: move.piece.getColor(), row: move.getRow(), file: move.getFile()))
    }
    
    private func isPawnPromotion(_ move: Move) -> Bool {
        return move.piece.getType() == .pawn && pawnHasReachedEndOfTheBoard(move)
    }
    
    private func doesMovePutOwnKingInCheck(_ move: Move) -> Bool {
        if CastlingRules.isCastlingMove(move) {
            return CastlingRules.pathIsInCheck(move, position: self)
        }
        
        let figures = getFigures()
        guard let king = figures.first(where: { $0.getType() == .king && $0.getColor() == move.piece.getColor() }) else { return true }
        let isKingMove = move.piece.getType() == .king
        let rowToCheck = isKingMove ? move.getRow() : king.getRow()
        let fileToCheck = isKingMove ? move.getFile() : king.getFile()
        let newPos = applying(move)

        return figures.contains(where: {
            guard $0.getColor() != getColorToMove() else { return false }
            return $0.isMovePossible($0.createMove(rowToCheck, fileToCheck, MoveType.Normal), position: newPos)
        })
    }
    
    private func isMoveInBoard(_ move:Move) -> Bool {
        return 1...8 ~= move.row && 1...8 ~= move.file
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
        return (move.piece.getColor() == .white && move.row == 8) || (move.piece.getColor() == .black && move.row == 1)
    }
    
    private static func createCacheDict(_ figures: [any ChessFigure]) -> [Int : [Int : any ChessFigure]]? {
        var dict:[Int:[Int:any ChessFigure]] = [:]
        for f in figures {
            if dict[f.getRow()] == nil {
                dict[f.getRow()] = [:]
            }
            guard dict[f.getRow()]?[f.getFile()] == nil else {
                Position.logger.error("could not set \(f.info()) because field is occupied by \(dict[f.getRow()]?[f.getFile()]?.info() ?? "")")
                return nil
            }
            dict[f.getRow()]![f.getFile()] = f
        }
        return dict
    }
}
