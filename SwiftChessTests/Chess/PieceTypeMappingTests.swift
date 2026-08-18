import XCTest
@testable import SwiftChess

final class PieceTypeMappingTests: XCTestCase {

    func testFenChar_uppercaseForWhite() {
        XCTAssertEqual(PieceType.pawn.fenChar(for: .white), "P")
        XCTAssertEqual(PieceType.knight.fenChar(for: .white), "N")
        XCTAssertEqual(PieceType.bishop.fenChar(for: .white), "B")
        XCTAssertEqual(PieceType.rook.fenChar(for: .white), "R")
        XCTAssertEqual(PieceType.queen.fenChar(for: .white), "Q")
        XCTAssertEqual(PieceType.king.fenChar(for: .white), "K")
    }

    func testFenChar_lowercaseForBlack() {
        XCTAssertEqual(PieceType.pawn.fenChar(for: .black), "p")
        XCTAssertEqual(PieceType.knight.fenChar(for: .black), "n")
        XCTAssertEqual(PieceType.bishop.fenChar(for: .black), "b")
        XCTAssertEqual(PieceType.rook.fenChar(for: .black), "r")
        XCTAssertEqual(PieceType.queen.fenChar(for: .black), "q")
        XCTAssertEqual(PieceType.king.fenChar(for: .black), "k")
    }

    func testInitFenChar_isCaseInsensitive() {
        XCTAssertEqual(PieceType(fenChar: "N"), .knight)
        XCTAssertEqual(PieceType(fenChar: "n"), .knight)
        XCTAssertEqual(PieceType(fenChar: "P"), .pawn)
        XCTAssertEqual(PieceType(fenChar: "q"), .queen)
        XCTAssertEqual(PieceType(fenChar: "k"), .king)
    }

    func testInitFenChar_unknownReturnsNil() {
        XCTAssertNil(PieceType(fenChar: "x"))
        XCTAssertNil(PieceType(fenChar: "1"))
        XCTAssertNil(PieceType(fenChar: "-"))
    }

    func testFenCharRoundTrips() {
        for type in [PieceType.pawn, .knight, .bishop, .rook, .queen, .king] {
            XCTAssertEqual(PieceType(fenChar: type.fenChar(for: .white)), type)
            XCTAssertEqual(PieceType(fenChar: type.fenChar(for: .black)), type)
        }
    }

    func testSanIdent() {
        XCTAssertEqual(PieceType.pawn.sanIdent, "")
        XCTAssertEqual(PieceType.knight.sanIdent, "N")
        XCTAssertEqual(PieceType.bishop.sanIdent, "B")
        XCTAssertEqual(PieceType.rook.sanIdent, "R")
        XCTAssertEqual(PieceType.queen.sanIdent, "Q")
        XCTAssertEqual(PieceType.king.sanIdent, "K")
    }
}
