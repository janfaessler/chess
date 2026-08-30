import Foundation

public enum FenBuilder {

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
        
        for row in stride(from: BoardConstants.size, to: 0, by: -1) {
            var emptyCount = 0
            for file in 1...BoardConstants.size {
                if position.isEmpty(atRow: row, atFile: file) {
                    emptyCount += 1
                    if file == BoardConstants.size {
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
        let rights = pos.castlingRights
        if rights.isEmpty { return "-" }
        var output = ""
        if rights.whiteKingside  { output.append("K") }
        if rights.whiteQueenside { output.append("Q") }
        if rights.blackKingside  { output.append("k") }
        if rights.blackQueenside { output.append("q") }
        return output
    }
    
    private static func createEnPassantTarget(_ field:Square?) -> String {
        return field?.info ?? "-"
    }
    
    private static func getPieceIdent(_ fig:any ChessPiece) -> String {
        return String(fig.type.fenChar(for: fig.color))
    }
}
