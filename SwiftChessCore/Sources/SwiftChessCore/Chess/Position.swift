import Foundation

public final class Position: @unchecked Sendable {

    private let board:Board
    public let colorToMove:PieceColor
    public let enPassantTarget:Field?
    public let canWhiteCastleKingside:Bool
    public let canWhiteCastleQueenside:Bool
    public let canBlackCastleKingside:Bool
    public let canBlackCastleQueenside:Bool
    public let halfmoveClock:Int
    public let moveClock:Int

    public var figures:[any ChessFigure] { board.figures }

    private var cachedHash:Int?

    public init(
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
        self.board = Board(figures)
        self.colorToMove = colorToMove
        self.enPassantTarget = enPassantTarget
        self.canWhiteCastleKingside = whiteCanCastleKingside
        self.canWhiteCastleQueenside = whiteCanCastleQueenside
        self.canBlackCastleKingside = blackCanCastleKingside
        self.canBlackCastleQueenside = blackCanCastleQueenside
        self.moveClock = moveClock
        self.halfmoveClock = halfmoveClock
    }
    
    public func get(atRow:Int, atFile:Int) -> (any ChessFigure)? {
        return board.get(atRow: atRow, atFile: atFile)
    }

    public func isEmpty(atRow:Int, atFile:Int) -> Bool {
        return board.isEmpty(atRow: atRow, atFile: atFile)
    }

    public func isNotEmpty(atRow:Int, atFile:Int) -> Bool {
        return board.isNotEmpty(atRow: atRow, atFile: atFile)
    }

    func checkNextIntersection(_ move: Move) -> (any ChessFigure)? {
        return board.checkNextIntersection(move)
    }

    public func getHash() -> Int {
        if let cachedHash { return cachedHash }
        let hash = computeHash()
        cachedHash = hash
        return hash
    }

    private func computeHash() -> Int {
        var hasher = Hasher()
        board.hash(into: &hasher)
        hasher.combine(colorToMove)
        hasher.combine(canWhiteCastleKingside)
        hasher.combine(canWhiteCastleQueenside)
        hasher.combine(canBlackCastleKingside)
        hasher.combine(canBlackCastleQueenside)
        hasher.combine(enPassantTarget)
        return hasher.finalize()
    }
    
    public func applying(_ move: Move) -> Position {
        var figures = figures
        let capturedPiece = applyCapture(&figures, move: move)
        applyMovement(&figures, move: move, capturedPiece: capturedPiece)
        if CastlingRules.isCastlingMove(move) { applyCastlingRook(&figures, move: move) }
        if PromotionRules.isPromotion(move) { applyPromotion(&figures, move: move) }
        return PositionFactory.create(self, afterMove: move, figures: figures, capturedPiece: capturedPiece)
    }
    
    private func applyCapture(_ figures: inout [any ChessFigure], move: Move) -> (any ChessFigure)? {
        let capturedPiece = get(atRow: move.row, atFile: move.file)
        figures.removeAll(where: { $0.equals(move.piece) || capturedPiece?.equals($0) == true })
        return capturedPiece
    }
    
    private func applyMovement(_ figures: inout [any ChessFigure], move: Move, capturedPiece: (any ChessFigure)?) {
        if EnPassantRules.isEnPassant(move, position: self) {
            let captured = EnPassantRules.capturedPawnField(for: move)
            figures.removeAll(where: { $0.row == captured.row && $0.file == captured.file })
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
        figures.removeAll(where: { PromotionRules.isPawnBeingPromoted($0, by: move) })
        figures.append(Figure.create(type: move.promoteTo, color: move.piece.color, row: move.row, file: move.file))
    }
}
