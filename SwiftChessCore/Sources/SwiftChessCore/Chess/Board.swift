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
    let hash: UInt64

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

    private init(grid: [StoredPiece?], figures: [any ChessPiece], hash: UInt64) {
        self.grid = grid
        self.figures = figures
        self.hash = hash
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
        let (newGrid, newFigures, newHash) = getUpdatedState(after: move, enPassantTarget: enPassantTarget)

        return (Board(grid: newGrid, figures: newFigures, hash: newHash), capturedPiece)
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
    
    private func getUpdatedState(after move: Move, enPassantTarget: Square?) -> (grid: [StoredPiece?], figures: [any ChessPiece], hash: UInt64) {
        var newGrid = grid
        var newFigures = figures
        var newHash = hash

        removeStoredPiece(atRow: move.startingSquare.row, atFile: move.startingSquare.file, from: &newGrid, figures: &newFigures, hash: &newHash)
        removeStoredPiece(atRow: move.row, atFile: move.file, from: &newGrid, figures: &newFigures, hash: &newHash)

        if move.pieceType == .pawn,
           let target = enPassantTarget,
           move.square == target,
           isEmpty(atRow: move.row, atFile: move.file) {
            let sq = EnPassantRules.capturedPawnSquare(for: move)
            removeStoredPiece(atRow: sq.row, atFile: sq.file, from: &newGrid, figures: &newFigures, hash: &newHash)
        }

        if let (fromFile, toFile) = CastlingRules.castlingRookMove(for: move) {
            removeStoredPiece(atRow: move.startingSquare.row, atFile: fromFile, from: &newGrid, figures: &newFigures, hash: &newHash)
            placeStoredPiece(StoredPiece(type: .rook, color: move.color, moved: true), atRow: move.startingSquare.row, atFile: toFile, in: &newGrid, figures: &newFigures, hash: &newHash)
        }

        let placedPiece: StoredPiece = PromotionRules.isPromotion(move)
            ? StoredPiece(type: move.promoteTo.pieceType, color: move.color, moved: false)
            : StoredPiece(type: move.pieceType, color: move.color, moved: true)
        placeStoredPiece(placedPiece, atRow: move.row, atFile: move.file, in: &newGrid, figures: &newFigures, hash: &newHash)

        return (newGrid, newFigures, newHash)
    }

    private func removeStoredPiece(atRow row: Int, atFile file: Int, from grid: inout [StoredPiece?], figures: inout [any ChessPiece], hash: inout UInt64) {
        let index = Board.index(row: row, file: file)
        guard let stored = grid[index] else { return }
        hash ^= BoardConstants.zobristValue(square: index, type: stored.type, color: stored.color)
        grid[index] = nil
        if let figureIndex = figures.firstIndex(where: { $0.row == row && $0.file == file }) {
            figures.remove(at: figureIndex)
        }
    }

    private func placeStoredPiece(_ piece: StoredPiece, atRow row: Int, atFile file: Int, in grid: inout [StoredPiece?], figures: inout [any ChessPiece], hash: inout UInt64) {
        let index = Board.index(row: row, file: file)
        grid[index] = piece
        hash ^= BoardConstants.zobristValue(square: index, type: piece.type, color: piece.color)
        figures.append(PieceFactory.create(type: piece.type, color: piece.color, row: row, file: file, moved: piece.moved))
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
    
    private static func computeHash(_ figures: [any ChessPiece]) -> UInt64 {
        figures.reduce(UInt64(0)) { hash, fig in
            hash ^ BoardConstants.zobristValue(square: Board.index(row: fig.row, file: fig.file), type: fig.type, color: fig.color)
        }
    }
}
