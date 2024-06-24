import Foundation

public class Position {
    
    private var cache:[Int:[Int:any ChessFigure]]
    private let colorToMove:PieceColor
    private let enPassantTarget:Field?
    private let whiteCanCastleKingside:Bool
    private let whiteCanCastleQueenside:Bool
    private let blackCanCastleKingside:Bool
    private let blackCanCastleQueenside:Bool
    private let halfmoveClock:Int
    private let moveClock:Int
    
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
        self.cache = Position.createCachDictionary(figures)
        self.colorToMove = colorToMove
        self.enPassantTarget = enPassantTarget
        self.whiteCanCastleKingside = whiteCanCastleKingside
        self.whiteCanCastleQueenside = whiteCanCastleQueenside
        self.blackCanCastleKingside = blackCanCastleKingside
        self.blackCanCastleQueenside = blackCanCastleQueenside
        self.moveClock = moveClock
        self.halfmoveClock = halfmoveClock
    }
    
    public func get(atRow:Int, atFile:Int) -> (any ChessFigure)? {
        return cache[atRow]?[atFile]
    }
    
    public func clearField(atRow:Int, atFile:Int) {
        cache[atRow]?[atFile] = nil
    }
    
    public func set(_ figure:any ChessFigure) {
        if cache[figure.getRow()] == nil {
            cache[figure.getRow()] = [:]
        }
        cache[figure.getRow()]![figure.getFile()] = figure
    }
    
    public func isEmpty(atRow:Int, atFile:Int) -> Bool {
        return get(atRow: atRow, atFile: atFile) == nil
    }
    
    public func isNotEmpty(atRow:Int, atFile:Int) -> Bool {
        return isEmpty(atRow: atRow, atFile: atFile) == false
    }
    
    public func getColorToMove() -> PieceColor {
        return colorToMove
    }
    
    public func getEnPassentTarget() -> Field? {
        return enPassantTarget
    }
    
    public func canWhiteCastleKingside() -> Bool {
        return whiteCanCastleKingside
    }
    
    public func canWhiteCastleQueenside() -> Bool {
        return whiteCanCastleQueenside
    }
    
    public func canBlackCastleKingside() -> Bool {
        return blackCanCastleKingside
    }
    
    public func canBlackCastleQueenside() -> Bool {
        return blackCanCastleQueenside
    }
    
    public func getMoveClock() -> Int {
        return moveClock
    }

    public func getHalfmoveClock() -> Int {
        return halfmoveClock
    }

    public func getFigures() -> [any ChessFigure] {
        return cache.flatMap({ $1.values })
    }
    
    public func getNextPiece(_ move: Move) -> (any ChessFigure)? {
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
    
    public func isCheck(_ move:Move) -> Bool {
        let opponentKing = getFigures().first(where: { $0.getType() == .king && $0.getColor() != move.piece.getColor()})
        let newPosition = createWithMove(move)
        return newPosition.isFieldInCheck(opponentKing!.getRow(), opponentKing!.getFile())
    }
    
    public func isFieldInCheck(_ row: Int, _ file: Int) -> Bool {
        let figures = getFigures()
        return figures.contains(where: {
            
            if $0.getColor() == colorToMove{ return false }
            let movepossible = $0.isMovePossible(Move(row, file, piece: $0), position: self)
            return movepossible
        })
    }
    
    public func isCheckMate(_ move:Move) -> Bool {
        let newPosition = createWithMove(move)
        let isCheckMate = !newPosition.playerHasLegalMove() && newPosition.isKingInCheck()
        return isCheckMate
    }
    
    public func IsMoveLegalMoveOnTheBoard(_ target:Move) -> Bool {
        guard isMoveInBoard(target) else { return false }
        guard target.piece.isMovePossible(target, position: self) else { return false }
        guard !doesMovePutOwnKingInCheck(target) else { return false }
        return true
    }
    
    public func playerHasLegalMove() -> Bool {
        let figuresOfCurrentPlayer = getFigures().filter({ $0.getColor() == colorToMove })
        return figuresOfCurrentPlayer.contains(where: { fig in fig.getPossibleMoves().contains(where: { move in IsMoveLegalMoveOnTheBoard(move) }) })
    }
    
    public func isKingInCheck() -> Bool {
        let king = getFigures().first(where: { $0.getType() == .king && $0.getColor() == getColorToMove()})!
        return isFieldInCheck(king.getRow(), king.getFile())
    }
    
    public func isLongCastling(_ move: Move) -> Bool {
        let castlingPossible = move.piece.getColor() == .white ? whiteCanCastleQueenside : blackCanCastleQueenside
        return move.file == King.CastleQueensidePosition && move.isCastling() && castlingPossible
    }
    
    public func isShortCastling(_ move: Move) -> Bool {
        let castlingPossible = move.piece.getColor() == .white ? whiteCanCastleKingside : blackCanCastleKingside
        return move.file == King.CastleKingsidePosition && move.isCastling() && castlingPossible
    }
    
    public func isEnPassant(_ move:Move) -> Bool {
        canEnPassant(move) && isEmpty(atRow: move.row, atFile: move.file) && enPassantTarget == move.getField()
    }
    
    public func canEnPassant(_ move:Move) -> Bool {
        guard let target = getEnPassentTarget() else { return false }
        
        return move.getField() == target
    }
    
    public func moveRookForCastling(_ move: Move) {
        if isLongCastling(move) {
            let rook = get(atRow: move.piece.getRow(), atFile: Rook.CastleQueensideStartingFile)!
            rook.move(row: move.row, file: Rook.CastleQueensideEndFile)
            clearField(atRow: move.piece.getRow(), atFile: Rook.CastleQueensideStartingFile)
            set(rook)
        } else if isShortCastling(move) {
            let rook = get(atRow: move.piece.getRow(), atFile: Rook.CastleKingsideStartingFile)!
            rook.move(row: move.row, file: Rook.CastleKingsideEndFile)
            clearField(atRow: move.piece.getRow(), atFile: Rook.CastleKingsideStartingFile)
            set(rook)
        }
    }
    public func checkPromotion(_ move: Move){
        guard
            move.piece.getType() == .pawn,
            pawnHasReachedEndOfTheBoard(move)
        else { return }

        promote(Pawn(color: move.piece.getColor(), row: move.getRow(), file: move.getFile()),
                to: Figure.create(type: move.promoteTo, color: move.piece.getColor(), row: move.getRow(), file: move.getFile()))
    }
    
    private func promote(_ pawn: Figure, to:any ChessFigure) {
        clearField(atRow: pawn.getRow(), atFile: pawn.getFile())
        set(to)
    }
    
    private func doesMovePutOwnKingInCheck(_ move:Move) -> Bool {
        
        let isKingMKove = move.piece.getType() == .king
        let figures = getFigures()
        let king = figures.first(where: { $0.getType() == .king && $0.getColor() == move.piece.getColor() })!
        let rowToCheck = isKingMKove ? move.getRow() : king.getRow()
        let fileToCheck = isKingMKove ? move.getFile() : king.getFile()
                
        let newPos = createWithMove(move)
        
        return figures.contains(where: {
            if $0.getColor() != getColorToMove() {
                if $0.isMovePossible($0.createMove(rowToCheck, fileToCheck, MoveType.Normal), position: newPos) {
                    return true
                } else {
                    return false
                }
            }
            return false
        })
    }
    
    private func isMoveInBoard(_ move:Move) -> Bool {
        return 1...8 ~= move.row && 1...8 ~= move.file
    }

    public func getHash() -> Int {
        var hasher = Hasher()
        for fig in getFigures().sorted(by: { $0.getRow() > $1.getRow() }).sorted(by: { $0.getFile() > $1.getFile() }) {
            hasher.combine(fig)
        }
        hasher.combine(enPassantTarget)
        return hasher.finalize()
    }
    
    public func createWithMove(_ move:Move) -> Position {
        let capturedPiece = get(atRow: move.getRow(), atFile: move.getFile())
        
        var figures = getFigures()
        figures.removeAll(where: { $0.equals(move.getPiece()) })
        figures.append(Figure.create(type: move.getPiece().getType(), color: move.getPiece().getColor(), row: move.getRow(), file: move.file, moved: true))
        
        let pos = PositionFactory.create(self, afterMove: move, figures: figures, capturedPiece: capturedPiece)
        pos.checkPromotion(move)
        pos.moveRookForCastling(move)
        return pos
    }
    
    
    private func getNextPieceOnRow(from:Field, to:Field) -> (any ChessFigure)? {
        let direction = from.file < to.file ? 1 : -1
        for f in stride(from: from.file + direction, to: to.file, by: direction)  {
            let foundPiece = get(atRow: from.row, atFile: f)
            if foundPiece != nil {
                return foundPiece
            }
        }
        return get(atRow: to.row, atFile: to.file)
    }
    
    private func getNextPieceOnFile(from:Field, to:Field) -> (any ChessFigure)? {
        let direction = from.row < to.row ? 1 : -1
        for r in stride(from: from.row + direction, to: to.row, by: direction) {
            let foundPiece = get(atRow: r, atFile: from.file)
            if foundPiece != nil {
                return foundPiece
            }
        }
        return get(atRow: to.row, atFile: to.file)

    }
    
    private func getNextPieceOnDiagonal(from:Field, to:Field) -> (any ChessFigure)? {
        let rowDir = min(max(to.row - from.row, -1), 1)
        let fileDir = min(max(to.file - from.file, -1), 1)
        let delta = abs(from.file - to.file)
        if delta > 1 {
            for i in 1...delta {
                let row = from.row+(i*rowDir)
                let file = from.file+(i*fileDir)
                let foundPiece = get(atRow: row, atFile: file)
                if foundPiece != nil {
                    return foundPiece
                }
            }
        }

        return get(atRow: to.row, atFile: to.file)
    }
    
    private func pawnHasReachedEndOfTheBoard(_ move:Move) -> Bool {
        return (move.piece.getColor() == .white && move.row == 8) || (move.piece.getColor() == .black && move.row == 1)
    }
    
    private static func createCachDictionary(_ figures: [any ChessFigure]) -> [Int : [Int : any ChessFigure]] {
        var dict:[Int:[Int:any ChessFigure]] = [:]

        for f in figures {
            if dict[f.getRow()] == nil {
                dict[f.getRow()] = [:]
            }
            dict[f.getRow()]![f.getFile()] = f
        }
        return dict
    }
}
