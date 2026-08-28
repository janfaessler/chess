import Foundation

enum FenError: Error { case malformed(String) }

public enum FenParser {

    public static func parse(_ fen:String) throws -> Position {
        let parts = fen.split(separator: " ").map({String($0)})

        guard parts.count == 6 else { throw FenError.malformed(fen) }
        guard isValidBoard(parts[0]) else { throw FenError.malformed(fen) }
        guard parts[1].lowercased() == "w" || parts[1].lowercased() == "b" else { throw FenError.malformed(fen) }
        guard isValidCastlingRights(parts[2]) else { throw FenError.malformed(fen) }
        guard isValidEnPassant(parts[3]) else { throw FenError.malformed(fen) }
        guard let halfmove = Int(parts[4]), halfmove <= BoardConstants.halfmoveClockLimit else { throw FenError.malformed(fen) }
        guard Int(parts[5]) != nil else { throw FenError.malformed(fen) }

        return Position(getPieces(parts[0]),
                        colorToMove: getNextMove(parts[1]),
                        enPassantTarget: getEnPassantTarget(parts[3]),
                        castlingRights: parseCastlingRights(parts[2]),
                        moveClock: parseInt(parts[5]) - 1,
                        halfmoveClock: halfmove)

    }

    private static func isValidBoard(_ board: String) -> Bool {
        guard board.split(separator: "/").count == 8 else { return false }
        let allowed = Set("pnbrqkPNBRQK12345678")
        return board.allSatisfy { $0 == "/" || allowed.contains($0) }
    }

    private static func isValidCastlingRights(_ str: String) -> Bool {
        str == "-" || (!str.isEmpty && str.allSatisfy { "KQkq".contains($0) } && Set(str).count == str.count)
    }

    private static func isValidEnPassant(_ str: String) -> Bool {
        str == "-" || Square(str) != nil
    }
    
    private static func getPieces(_ position: String) -> [any ChessPiece] {
        var figures:[any ChessPiece] = []
        var row = 8
        for rowPart in position.split(separator: "/") {
            let figuresLine = parseLine(rowPart, rowNumber: row)
            figures.append(contentsOf: figuresLine)
            row -= 1
        }
        return figures
    }
    
    private static func getNextMove(_ nextMove:String) -> PieceColor{
        return nextMove.lowercased() == "w" ? .white : .black
    }
    
    private static func parseCastlingRights(_ str: String) -> CastlingRights {
        CastlingRights(
            whiteKingside:  str.contains(PieceType.king.fenChar(for: .white)),
            whiteQueenside: str.contains(PieceType.queen.fenChar(for: .white)),
            blackKingside:  str.contains(PieceType.king.fenChar(for: .black)),
            blackQueenside: str.contains(PieceType.queen.fenChar(for: .black))
        )
    }

    private static func getEnPassantTarget(_ str:String) -> Square? {
        return Square(str)
    }
    
    private static func parseLine(_ rowPart: String.SubSequence,  rowNumber: Int) -> [any ChessPiece]{
        var figures:[any ChessPiece] = []
        var file = 1
        for part in rowPart {
            let digit = part.wholeNumberValue
            if (digit == nil) {
                guard let fig = parsePiece(part, rowNumber: rowNumber, fileNumber: file) else {
                    break
                }
                figures.append(fig)
                file += 1
            } else {
                file += digit!
            }
        }
        
        return figures
    }
    
    private static func parsePiece(_ str: Character, rowNumber:Int, fileNumber:Int) -> (any ChessPiece)? {
        let pieceType = PieceType(fenChar: str)
        let pieceColor = parseColor(str)
        return createPiece(pieceType, pieceColor, rowNumber, fileNumber)
    }
    
    private static func createPiece(_ pieceType: PieceType?, _ pieceColor: PieceColor, _ rowNumber: Int, _ fileNumber: Int) -> (any ChessPiece)? {
        switch (pieceType) {
            case .pawn:
                return Pawn(color: pieceColor, row: rowNumber, file: fileNumber)
            case .bishop:
                return Bishop(color: pieceColor, row: rowNumber, file: fileNumber)
            case .knight:
                return Knight(color: pieceColor, row: rowNumber, file: fileNumber)
            case .rook:
                return Rook(color: pieceColor, row: rowNumber, file: fileNumber)
            case .queen:
                return Queen(color: pieceColor, row: rowNumber, file: fileNumber)
            case .king:
                return King(color: pieceColor, row: rowNumber, file: fileNumber)
            case .none:
                return nil
        }
    }
    
    private static func parseColor(_ str:Character) -> PieceColor {
        return str.isLowercase ? .black : .white
    }
    
    private static func parseInt(_ str: String) -> Int {
        return Int(str) ?? 0
    }
}
