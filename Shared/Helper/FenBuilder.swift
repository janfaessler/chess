import Foundation

public class FenBuilder {
    
    public static func create(_ pos:Position) -> String {
        
        var output = createFigures(pos)
        output.append(" ")
        output.append(createNextMove(pos.getColorToMove()))
        output.append(" ")
        output.append(createCastlingRights(pos))
        output.append(" ")
        output.append(createEnPassantTarget(pos.getEnPassentTarget()))
        output.append(" \(pos.getHalfmoveClock()) \(pos.getMoveClock()+1)")

        return output
    }
    
    private static func createFigures(_ cache:Position) -> String {
        var output = ""
        
        for row in stride(from: 8, to: 0, by: -1) {
            var emptyCount = 0
            for file in 1...8 {
                if cache.isEmpty(atRow: row, atFile: file) {
                    emptyCount += 1
                    if file == 8 {
                        output.append("\(emptyCount)")
                    }
                } else {
                    if emptyCount > 0 {
                        output.append("\(emptyCount)")
                    }
                    let fig = cache.get(atRow: row, atFile: file)!
                    
                    output.append(getPieceIdent(fig))
                    emptyCount = 0
                }
            }
            if row > 1 {
                output.append("/")
            }
            emptyCount = 0
        }

        return output
    }
    
    private static func createNextMove(_ colorToMove:PieceColor) -> String {
        return colorToMove == .white ? "w" : "b"
    }
    
    private static func createCastlingRights(_ pos:Position) -> String {
        var output = ""
        if pos.canWhiteCastleKingside() {
            output.append("K")
        }
        if pos.canWhiteCastleQueenside() {
            output.append("Q")
        }
        if pos.canBlackCastleKingside() {
            output.append("k")
        }
        if pos.canBlackCastleQueenside() {
            output.append("q")
        }
        if !pos.canWhiteCastleKingside()
            && !pos.canWhiteCastleQueenside()
            && !pos.canBlackCastleKingside()
            && !pos.canBlackCastleQueenside() {
            output.append("-")
        }
        return output
    }
    
    private static func createEnPassantTarget(_ field:Field?) -> String {
        return field?.info() ?? "-"
    }
    
    private static func getPieceIdent(_ fig:any ChessFigure) -> String {
        switch fig.getType() {
        case .pawn:
            return fig.getColor() == .white ? "P" : "p"
        case .bishop:
            return fig.getColor() == .white ? Bishop.Ident.uppercased() : Bishop.Ident.lowercased()
        case .knight:
            return fig.getColor() == .white ? Knight.Ident.uppercased() : Knight.Ident.lowercased()
        case .rook:
            return fig.getColor() == .white ? Rook.Ident.uppercased() : Rook.Ident.lowercased()
        case .queen:
            return fig.getColor() == .white ? Queen.Ident.uppercased() : Queen.Ident.lowercased()
        case .king:
            return fig.getColor() == .white ? King.Ident.uppercased() : King.Ident.lowercased()
        }
    }
}
