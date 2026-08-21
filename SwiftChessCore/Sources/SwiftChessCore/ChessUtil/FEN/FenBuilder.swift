import Foundation

public class FenBuilder {

    public static func create(_ pos:Position) -> String {
        
        var output = createFigures(pos)
        output.append(" ")
        output.append(createNextMove(pos.colorToMove))
        output.append(" ")
        output.append(createCastlingRights(pos))
        output.append(" ")
        output.append(createEnPassantTarget(pos.enPassantTarget))
        output.append(" \(pos.halfmoveClock) \(pos.moveClock+1)")

        return output
    }
    
    private static func createFigures(_ position:Position) -> String {
        var output = ""
        
        for row in stride(from: 8, to: 0, by: -1) {
            var emptyCount = 0
            for file in 1...8 {
                if position.isEmpty(atRow: row, atFile: file) {
                    emptyCount += 1
                    if file == 8 {
                        output.append("\(emptyCount)")
                    }
                } else {
                    if emptyCount > 0 {
                        output.append("\(emptyCount)")
                    }
                    let fig = position.get(atRow: row, atFile: file)!
                    
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
        if pos.canWhiteCastleKingside {
            output.append("K")
        }
        if pos.canWhiteCastleQueenside {
            output.append("Q")
        }
        if pos.canBlackCastleKingside {
            output.append("k")
        }
        if pos.canBlackCastleQueenside {
            output.append("q")
        }
        if !pos.canWhiteCastleKingside
            && !pos.canWhiteCastleQueenside
            && !pos.canBlackCastleKingside
            && !pos.canBlackCastleQueenside {
            output.append("-")
        }
        return output
    }
    
    private static func createEnPassantTarget(_ field:Field?) -> String {
        return field?.info ?? "-"
    }
    
    private static func getPieceIdent(_ fig:any ChessFigure) -> String {
        return String(fig.type.fenChar(for: fig.color))
    }
}
