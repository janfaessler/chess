import Testing
@testable import SwiftChessCore

struct PgnParserTests {

    @Test func testParsingWithVariationsAndSubvariations() throws {

        let pgn =
"""
[Event "moep"]
[White "whites name"]
[Black "blacks name"]

{ initial game comment. } 1. e4 c6 {bla1}  2. d4 {bla2}  ( 2. Nc3 d5 3. Nf3 { bla bla.}  3... Bg4 { moep}  ( 3... dxe4 { bla bla ( sbla )  bla.}  4. Nxe4 Nf6 )( 3... a6 { bla3} )4. h3 Bxf3 5. Qxf3 e6 { [%csl Gb7,Gc1,Gc6,Gd5,Ge6,Gf1,Gf7] fu:}  )( 2. Nf3 d5 3. exd5 cxd5 4. d4 { bar.}  )2... d5 3. Nc3 { bla bla  ( 3. e5 ) .}  ( 3. e5 $1 { fu bar 3..c5!}  3... c5 $5 4. dxc5 $1  ( 4. c3 Nc6 5. Nf3 Bg4 6. Be2 e6 )( 4. c4 $5 )4... Nc6 $5 ( 4... e6))3... dxe4
"""

        let games = PgnParser.parse(pgn)
        let game = try #require(games.first)

        #expect(game.headers["Event"] == "moep")
        #expect(game.headers["White"] == "whites name")
        #expect(game.headers["Black"] == "blacks name")

        #expect(game.comment == "initial game comment.")
        #expect(game.moves[0].move == "e4")
        #expect(game.moves[1].move == "c6")
        #expect(game.moves[1].comment == "bla1")
        #expect(game.moves[2].move == "d4")
        #expect(game.moves[2].comment == "bla2")
        #expect(game.moves[2].variations[0][0].move == "Nc3")
        #expect(game.moves[2].variations[0][1].move == "d5")
        #expect(game.moves[2].variations[0][2].move == "Nf3")
        #expect(game.moves[2].variations[0][2].comment == "bla bla.")
        #expect(game.moves[2].variations[0][3].move == "Bg4")
        #expect(game.moves[2].variations[0][3].comment == "moep")

        #expect(game.moves[2].variations[0][3].variations[0][0].move == "dxe4")
        #expect(game.moves[2].variations[0][3].variations[0][0].comment == "bla bla ( sbla ) bla.")
        #expect(game.moves[2].variations[0][3].variations[0][1].move == "Nxe4")
        #expect(game.moves[2].variations[0][3].variations[0][2].move == "Nf6")

        #expect(game.moves[2].variations[0][3].variations[1][0].move == "a6")
        #expect(game.moves[2].variations[0][3].variations[1][0].comment == "bla3")

        #expect(game.moves[2].variations[0][4].move == "h3")
        #expect(game.moves[2].variations[0][5].move == "Bxf3")
        #expect(game.moves[2].variations[0][6].move == "Qxf3")
        #expect(game.moves[2].variations[0][7].move == "e6")
        // [%csl ...] stripped from comment text
        #expect(game.moves[2].variations[0][7].comment == "fu:")
        // highlights parsed from [%csl Gb7,Gc1,Gc6,Gd5,Ge6,Gf1,Gf7]
        #expect(game.moves[2].variations[0][7].highlights.count == 7)
        #expect(game.moves[2].variations[0][7].highlights[0] == SquareHighlight(color: .green, square: "b7"))
        #expect(game.moves[2].variations[0][7].highlights[6] == SquareHighlight(color: .green, square: "f7"))

        #expect(game.moves[2].variations[1][0].move == "Nf3")
        #expect(game.moves[2].variations[1][1].move == "d5")
        #expect(game.moves[2].variations[1][2].move == "exd5")
        #expect(game.moves[2].variations[1][3].move == "cxd5")
        #expect(game.moves[2].variations[1][4].move == "d4")
        #expect(game.moves[2].variations[1][4].comment == "bar.")

        #expect(game.moves[3].move == "d5")
        #expect(game.moves[4].move == "Nc3")
        #expect(game.moves[4].comment == "bla bla ( 3. e5 ) .")

        #expect(game.moves[4].variations[0][0].move == "e5")
        #expect(game.moves[4].variations[0][0].comment == "fu bar 3..c5!")
        #expect(game.moves[4].variations[0][0].annotation == .good)
        #expect(game.moves[4].variations[0][1].move == "c5")
        #expect(game.moves[4].variations[0][1].annotation == .interesting)
        #expect(game.moves[4].variations[0][2].move == "dxc5")
        #expect(game.moves[4].variations[0][2].annotation == .good)

        #expect(game.moves[4].variations[0][2].variations[0][0].move == "c3")
        #expect(game.moves[4].variations[0][2].variations[0][1].move == "Nc6")
        #expect(game.moves[4].variations[0][2].variations[0][2].move == "Nf3")
        #expect(game.moves[4].variations[0][2].variations[0][3].move == "Bg4")
        #expect(game.moves[4].variations[0][2].variations[0][4].move == "Be2")
        #expect(game.moves[4].variations[0][2].variations[0][5].move == "e6")

        #expect(game.moves[4].variations[0][2].variations[1][0].move == "c4")
        #expect(game.moves[4].variations[0][2].variations[1][0].annotation == .interesting)

        #expect(game.moves[4].variations[0][3].move == "Nc6")
        #expect(game.moves[4].variations[0][3].annotation == .interesting)
        #expect(game.moves[4].variations[0][3].variations[0][0].move == "e6")

        #expect(game.moves[5].move == "dxe4")
    }

    @Test func testParse_unterminatedComment_doesNotCrash() {
        let pgn = """
        [Event "x"]

        { this comment never closes
        1. e4 e5
        """
        let games = PgnParser.parse(pgn)
        #expect(!games.isEmpty)
    }

    @Test func testParse_multiLineComment_ok() {
        let pgn = """
        [Event "x"]

        { opening
        still going }
        1. e4 e5
        """
        let games = PgnParser.parse(pgn)
        #expect(!games.isEmpty)
    }

    @Test func testParse_commentOnlyLine_ok() throws {
        let pgn = """
        [Event "x"]

        {c}
        1. e4 e5
        """
        let games = PgnParser.parse(pgn)
        let game = try #require(games.first)
        #expect(game.comment == "c")
        #expect(game.moves.first?.move == "e4")
    }

    @Test func testParse_garbageMoveToken_skips() {
        let pgn = """
        [Event "x"]

        1. e4 e5 2.
        """
        let games = PgnParser.parse(pgn)
        #expect(!games.isEmpty)
    }

    @Test func testParse_cslHighlights() throws {
        let pgn = """
        [Event "x"]

        1. e4 { [%csl Rg4,Yh5,Gb2] some text } e5
        """
        let games = PgnParser.parse(pgn)
        let game = try #require(games.first)
        let move = try #require(game.moves.first)
        #expect(move.comment == "some text")
        #expect(move.highlights.count == 3)
        #expect(move.highlights[0] == SquareHighlight(color: .red, square: "g4"))
        #expect(move.highlights[1] == SquareHighlight(color: .yellow, square: "h5"))
        #expect(move.highlights[2] == SquareHighlight(color: .green, square: "b2"))
        #expect(move.arrows.isEmpty)
    }

    @Test func testParse_calArrows() throws {
        let pgn = """
        [Event "x"]

        1. e4 { [%cal Rg4g8,Yb2b8] } e5
        """
        let games = PgnParser.parse(pgn)
        let game = try #require(games.first)
        let move = try #require(game.moves.first)
        #expect(move.comment == nil)
        #expect(move.arrows.count == 2)
        #expect(move.arrows[0] == BoardArrow(color: .red, from: "g4", to: "g8"))
        #expect(move.arrows[1] == BoardArrow(color: .yellow, from: "b2", to: "b8"))
        #expect(move.highlights.isEmpty)
    }

    @Test func testParse_cslAndCalTogether() throws {
        let pgn = """
        [Event "x"]

        1. e4 { [%csl Ge4][%cal Ge4e5] Great square } e5
        """
        let games = PgnParser.parse(pgn)
        let game = try #require(games.first)
        let move = try #require(game.moves.first)
        #expect(move.comment == "Great square")
        #expect(move.highlights.count == 1)
        #expect(move.highlights[0] == SquareHighlight(color: .green, square: "e4"))
        #expect(move.arrows.count == 1)
        #expect(move.arrows[0] == BoardArrow(color: .green, from: "e4", to: "e5"))
    }

    @Test func testParse_nagAnnotation() throws {
        let pgn = """
        [Event "x"]

        1. e4 $3 e5 $4
        """
        let games = PgnParser.parse(pgn)
        let game = try #require(games.first)
        #expect(game.moves[0].annotation == .brilliant)
        #expect(game.moves[1].annotation == .blunder)
    }

    @Test func testParse_symbolicAnnotation() throws {
        let pgn = """
        [Event "x"]

        1. e4!! e5?
        """
        let games = PgnParser.parse(pgn)
        let game = try #require(games.first)
        #expect(game.moves[0].annotation == .brilliant)
        #expect(game.moves[1].annotation == .mistake)
    }

    @Test func testParse_unterminatedVariation_doesNotCrash() {
        let pgn = """
        [Event "x"]

        1. e4 e5 2. Nf3 ( 2. Nc3 d5
        """
        let games = PgnParser.parse(pgn)
        #expect(!games.isEmpty)
    }

    @Test func testParse_missingResultTag_parsesMovesWithUnknownResult() throws {
        let pgn = """
        [Event "x"]

        1. e4 e5 2. Nf3 Nc6
        """
        let games = PgnParser.parse(pgn)
        let game = try #require(games.first)
        #expect(game.moves.count == 4)
        #expect(game.moves[0].move == "e4")
        #expect(game.moves[3].move == "Nc6")
    }

    @Test func testParse_annotationOnLastMove_parsed() throws {
        let pgn = """
        [Event "x"]

        1. e4 e5!! 1-0
        """
        let games = PgnParser.parse(pgn)
        let game = try #require(games.first)
        #expect(game.moves.count == 2)
        #expect(game.moves[1].annotation == .brilliant)
    }
}
