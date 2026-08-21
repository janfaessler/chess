import Testing
@testable import SwiftChessCore

struct FenTests {

    @Test func testExample() throws {
        let fens = [
            PositionFactory.startingPositionFen,
            "8/5k2/8/3K4/8/8/8/8 w - - 0 1",
            "8/5k2/8/3K1b2/8/8/8/8 w - - 0 1",
            "8/5k2/8/3K4/8/2B5/8/8 w - - 0 1",
            "8/5k2/8/3K4/6n1/8/8/8 w - - 0 1",
            "8/5k2/8/3K4/8/8/5N2/8 w - - 0 1",
            "8/5k2/b7/3K4/6B1/8/8/8 w - - 0 1",
            "8/5k2/b7/3K4/7B/8/8/8 w - - 0 10",
            "8/5k2/8/3K1b2/8/8/8/6r1 w - - 0 10",
            "8/5k2/8/3K1b2/8/8/1n6/8 w - - 0 10",
        ]

        for fen in fens {
            let pos = try #require(PositionFactory.loadPosition(fen))
            let board = ChessGame(pos)
            let exportedFen = FenBuilder.create(board.position)
            #expect(fen == exportedFen)
        }
    }

    @Test func testParse_tooFewFields_throws() {
        #expect(throws: (any Error).self) {
            try FenParser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -")
        }
    }

    @Test func testParse_emptyString_throws() {
        #expect(throws: (any Error).self) {
            try FenParser.parse("")
        }
    }

    @Test func testParse_garbageBoard_throws() {
        #expect(throws: (any Error).self) {
            try FenParser.parse("this-is-not-a-board w KQkq - 0 1")
        }
    }

    @Test func testParse_validFen_doesNotThrow() throws {
        _ = try FenParser.parse(PositionFactory.startingPositionFen)
    }
}
