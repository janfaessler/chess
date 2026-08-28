import Foundation

public enum PieceFactory {

    public static func create(_ squareName: String, type: PieceType, color: PieceColor, moved: Bool = false) -> (any ChessPiece)? {
        guard let square = Square(squareName) else { return nil }
        return create(type: type, color: color, row: square.row, file: square.file, moved: moved)
    }

    public static func create(type: PieceType, color: PieceColor, row: Int, file: Int, moved: Bool = false) -> any ChessPiece {
        switch type {
        case .pawn:   return Pawn(color: color, row: row, file: file, moved: moved)
        case .knight: return Knight(color: color, row: row, file: file, moved: moved)
        case .bishop: return Bishop(color: color, row: row, file: file, moved: moved)
        case .rook:   return Rook(color: color, row: row, file: file, moved: moved)
        case .queen:  return Queen(color: color, row: row, file: file, moved: moved)
        case .king:   return King(color: color, row: row, file: file, moved: moved)
        }
    }
}
