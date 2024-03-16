import Foundation

public class BoardCache {
    
    private var hasher = Hasher()

    private var cache:[Int:[Int:any ChessFigure]]
    private let colorToMove:PieceColor
    private let enPassantTarget:Field?
    
    private init(_ cache:[Int:[Int:any ChessFigure]], colorToMove:PieceColor, enPassentTarget:Field?) {
        self.cache = cache
        self.colorToMove = colorToMove
        self.enPassantTarget = enPassentTarget
    }
    
    public static func create(_ figures: [any ChessFigure], lastMove:Move? = nil) -> BoardCache {
        let dict = createCachDictionary(figures)
        let colorToMove = createColorToMove(lastMove)
        let enPassantTarget = createEnPassantTarget(lastMove)
            
        return BoardCache(dict, colorToMove: colorToMove, enPassentTarget: enPassantTarget)
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
    
    public func getFigures() -> [any ChessFigure] {
        return cache.flatMap({ fileKey, row in return row.values})
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
    
    public func isFieldInCheck(_ row: Int, _ file: Int) -> Bool {
        let figures = getFigures()
        return figures.contains(where: {
            
            if $0.getColor() == colorToMove{ return false }
            let movepossible = $0.isMovePossible(Move(row, file, piece: $0), cache: self)
            return movepossible
        })
    }
    
    public func getHash() -> Int {
        var hasher = Hasher()
        for fig in getFigures().sorted(by: { $0.getRow() > $1.getRow() }).sorted(by: { $0.getFile() > $1.getFile() }) {
            hasher.combine(fig)
        }
        hasher.combine(enPassantTarget)
        return hasher.finalize()
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
    
    private static func createColorToMove(_ move:Move?) -> PieceColor {
        return  move?.piece.getColor() == .white ? .black : .white
    }
    
    private static func createEnPassantTarget(_ move:Move?) -> Field? {
        guard move?.type == .Double else { return nil }
        
        let targetRow = move!.piece.getColor() == .white ? move!.getRow() - 1 : move!.getRow() + 1
        let targetFile = move!.getFile()
        
        return Field(row:targetRow, file: targetFile)
    }
}
