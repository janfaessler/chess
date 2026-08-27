import Testing
@testable import SwiftChessCore

struct PieceTypeMappingTests {

    @Test func testFenChar_uppercaseForWhite() {
        #expect(PieceType.pawn.fenChar(for: .white) == "P")
        #expect(PieceType.knight.fenChar(for: .white) == "N")
        #expect(PieceType.bishop.fenChar(for: .white) == "B")
        #expect(PieceType.rook.fenChar(for: .white) == "R")
        #expect(PieceType.queen.fenChar(for: .white) == "Q")
        #expect(PieceType.king.fenChar(for: .white) == "K")
    }

    @Test func testFenChar_lowercaseForBlack() {
        #expect(PieceType.pawn.fenChar(for: .black) == "p")
        #expect(PieceType.knight.fenChar(for: .black) == "n")
        #expect(PieceType.bishop.fenChar(for: .black) == "b")
        #expect(PieceType.rook.fenChar(for: .black) == "r")
        #expect(PieceType.queen.fenChar(for: .black) == "q")
        #expect(PieceType.king.fenChar(for: .black) == "k")
    }

    @Test func testInitFenChar_isCaseInsensitive() {
        #expect(PieceType(fenChar: "N") == .knight)
        #expect(PieceType(fenChar: "n") == .knight)
        #expect(PieceType(fenChar: "P") == .pawn)
        #expect(PieceType(fenChar: "q") == .queen)
        #expect(PieceType(fenChar: "k") == .king)
    }

    @Test func testInitFenChar_unknownReturnsNil() {
        #expect(PieceType(fenChar: "x") == nil)
        #expect(PieceType(fenChar: "1") == nil)
        #expect(PieceType(fenChar: "-") == nil)
    }

    @Test func testFenCharRoundTrips() {
        for type in [PieceType.pawn, .knight, .bishop, .rook, .queen, .king] {
            #expect(PieceType(fenChar: type.fenChar(for: .white)) == type)
            #expect(PieceType(fenChar: type.fenChar(for: .black)) == type)
        }
    }

}
