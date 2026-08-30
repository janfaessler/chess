import Foundation

struct StoredPiece: Hashable {
    let type: PieceType
    let color: PieceColor
    let moved: Bool
}

struct Board: BoardQuery, Sendable, Hashable {

    private static let logger = Log.logger("Board")

    private let grid: [StoredPiece?]
    let figures: [any ChessPiece]
    let hash: Int

    init?(_ figures: [any ChessPiece]) {
        guard let grid = Board.createGrid(figures) else { return nil }
        self.init(grid: grid)
    }

    init(grid: [StoredPiece?]) {
        let figures = Board.getFigures(grid)
        self.grid = grid
        self.figures = figures
        self.hash = Board.computeHash(figures)
    }

    func get(atRow: Int, atFile: Int) -> (any ChessPiece)? {
        let index = Board.index(row: atRow, file: atFile)
        guard let stored = grid[index] else { return nil }
        return PieceFactory.create(type: stored.type, color: stored.color, row: atRow, file: atFile, moved: stored.moved)
    }

    func isEmpty(atRow: Int, atFile: Int) -> Bool {
        grid[Board.index(row: atRow, file: atFile)] == nil
    }

    func isNotEmpty(atRow: Int, atFile: Int) -> Bool {
        grid[Board.index(row: atRow, file: atFile)] != nil
    }

    func checkNextIntersection(_ move: Move) -> (any ChessPiece)? {
        PathChecker(self).firstPieceOnPath(from: move.startingSquare, to: move.square)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }

    func applying(_ move: Move, enPassantTarget: Square?) -> (Board, (any ChessPiece)?) {
        let capturedPiece = get(atRow: move.row, atFile: move.file)
        let newGrid = getUpdatedCache(after: move, enPassantTarget: enPassantTarget)

        return (Board(grid: newGrid), capturedPiece)
    }
    
    static func == (lhs: Board, rhs: Board) -> Bool {
        lhs.grid == rhs.grid
    }
    
    private static func createGrid(_ figures: [any ChessPiece]) -> [StoredPiece?]? {
        var grid: [StoredPiece?] = Array(repeating: nil, count: 64)
        for figure in figures {
            let idx = Board.index(row: figure.row, file: figure.file)
            guard grid[idx] == nil else {
                logger.error("could not set \(figure.info()) because field is occupied")
                return nil
            }
            grid[idx] = StoredPiece(type: figure.type, color: figure.color, moved: figure.hasMoved())
        }
        return grid
    }
    
    private func getUpdatedCache(after: Move, enPassantTarget: Square?) -> [StoredPiece?] {
        let move = after
        var newGrid = grid

        newGrid[Board.index(row: move.startingSquare.row, file: move.startingSquare.file)] = nil
        newGrid[Board.index(row: move.row, file: move.file)] = nil

        if let target = enPassantTarget,
           move.square == target,
           isEmpty(atRow: move.row, atFile: move.file) {
            let sq = EnPassantRules.capturedPawnSquare(for: move)
            newGrid[Board.index(row: sq.row, file: sq.file)] = nil
        }

        if let (fromFile, toFile) = CastlingRules.castlingRookMove(for: move) {
            newGrid[Board.index(row: move.startingSquare.row, file: fromFile)] = nil
            newGrid[Board.index(row: move.startingSquare.row, file: toFile)] =
                StoredPiece(type: .rook, color: move.color, moved: true)
        }

        if PromotionRules.isPromotion(move) {
            newGrid[Board.index(row: move.row, file: move.file)] =
                StoredPiece(type: move.promoteTo.pieceType, color: move.color, moved: false)
        } else {
            newGrid[Board.index(row: move.row, file: move.file)] =
                StoredPiece(type: move.pieceType, color: move.color, moved: true)
        }
        return newGrid
    }
    

    private static func getFigures(_ grid: [StoredPiece?]) -> [any ChessPiece] {
        grid.indices.compactMap { idx in
            guard let stored = grid[idx] else { return nil }
            return PieceFactory.create(
                type: stored.type,
                color: stored.color,
                row: idx / 8 + 1,
                file: idx % 8 + 1,
                moved: stored.moved
            )
        }
    }
    
    private static func index(row: Int, file: Int) -> Int {
        (row - 1) &* 8 + (file - 1)
    }
    
    private static func computeHash(_ figures: [any ChessPiece]) -> Int {
        var hasher = Hasher()
        for fig in figures {
            hasher.combine(fig)
        }
        return hasher.finalize()
    }
}
