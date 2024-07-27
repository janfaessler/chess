import XCTest
import SwiftChess

final class PgnParserTests: XCTestCase {


    func testParsingWithVariationsAndSubvariations() throws {
        
        let pgn = 
"""
[Event "moep"]
[White "whites name"]
[Black "blacks name"]

{ initial game comment. } 1. e4 c6 {bla1}  2. d4 {bla2}  ( 2. Nc3 d5 3. Nf3 { bla bla.}  3... Bg4 { moep}  ( 3... dxe4 { bla bla ( sbla )  bla.}  4. Nxe4 Nf6 )( 3... a6 { bla3} )4. h3 Bxf3 5. Qxf3 e6 { [%csl Gb7,Gc1,Gc6,Gd5,Ge6,Gf1,Gf7] fu:}  )( 2. Nf3 d5 3. exd5 cxd5 4. d4 { bar.}  )2... d5 3. Nc3 { bla bla  ( 3. e5 ) .}  ( 3. e5 $1 { fu bar 3..c5!}  3... c5 $5 4. dxc5 $1  ( 4. c3 Nc6 5. Nf3 Bg4 6. Be2 e6 )( 4. c4 $5 )4... Nc6 $5 ( 4... e6))3... dxe4
"""
        
    
        let games = PgnParser.parse(pgn)
        let game = games.first!
        
        XCTAssertEqual(game.headers["Event"], "moep")
        XCTAssertEqual(game.headers["White"], "whites name")
        XCTAssertEqual(game.headers["Black"], "blacks name")
        
        XCTAssertEqual(game.comment, "initial game comment.")
        XCTAssertEqual(game.moves[0].move, "e4")
        XCTAssertEqual(game.moves[1].move, "c6")
        XCTAssertEqual(game.moves[1].comment, "bla1")
        XCTAssertEqual(game.moves[2].move, "d4")
        XCTAssertEqual(game.moves[2].comment, "bla2")
        XCTAssertEqual(game.moves[2].variations[0][0].move, "Nc3")
        XCTAssertEqual(game.moves[2].variations[0][1].move, "d5")
        XCTAssertEqual(game.moves[2].variations[0][2].move, "Nf3")
        XCTAssertEqual(game.moves[2].variations[0][2].comment, "bla bla.")
        XCTAssertEqual(game.moves[2].variations[0][3].move, "Bg4")
        XCTAssertEqual(game.moves[2].variations[0][3].comment, "moep")
        
        XCTAssertEqual(game.moves[2].variations[0][3].variations[0][0].move, "dxe4")
        XCTAssertEqual(game.moves[2].variations[0][3].variations[0][0].comment, "bla bla ( sbla ) bla.")
        XCTAssertEqual(game.moves[2].variations[0][3].variations[0][1].move, "Nxe4")
        XCTAssertEqual(game.moves[2].variations[0][3].variations[0][2].move, "Nf6")
        
        XCTAssertEqual(game.moves[2].variations[0][3].variations[1][0].move, "a6")
        XCTAssertEqual(game.moves[2].variations[0][3].variations[1][0].comment, "bla3")

        XCTAssertEqual(game.moves[2].variations[0][4].move, "h3")
        XCTAssertEqual(game.moves[2].variations[0][5].move, "Bxf3")
        XCTAssertEqual(game.moves[2].variations[0][6].move, "Qxf3")
        XCTAssertEqual(game.moves[2].variations[0][7].move, "e6")
        XCTAssertEqual(game.moves[2].variations[0][7].comment, "[%csl Gb7,Gc1,Gc6,Gd5,Ge6,Gf1,Gf7] fu:")
        
        XCTAssertEqual(game.moves[2].variations[1][0].move, "Nf3")
        XCTAssertEqual(game.moves[2].variations[1][1].move, "d5")
        XCTAssertEqual(game.moves[2].variations[1][2].move, "exd5")
        XCTAssertEqual(game.moves[2].variations[1][3].move, "cxd5")
        XCTAssertEqual(game.moves[2].variations[1][4].move, "d4")
        XCTAssertEqual(game.moves[2].variations[1][4].comment, "bar.")

        XCTAssertEqual(game.moves[3].move, "d5")
        XCTAssertEqual(game.moves[4].move, "Nc3")
        XCTAssertEqual(game.moves[4].comment, "bla bla ( 3. e5 ) .")
        
        XCTAssertEqual(game.moves[4].variations[0][0].move, "e5")
        XCTAssertEqual(game.moves[4].variations[0][0].comment, "fu bar 3..c5!")
        XCTAssertEqual(game.moves[4].variations[0][1].move, "c5")
        XCTAssertEqual(game.moves[4].variations[0][2].move, "dxc5")
        
        XCTAssertEqual(game.moves[4].variations[0][2].variations[0][0].move, "c3")
        XCTAssertEqual(game.moves[4].variations[0][2].variations[0][1].move, "Nc6")
        XCTAssertEqual(game.moves[4].variations[0][2].variations[0][2].move, "Nf3")
        XCTAssertEqual(game.moves[4].variations[0][2].variations[0][3].move, "Bg4")
        XCTAssertEqual(game.moves[4].variations[0][2].variations[0][4].move, "Be2")
        XCTAssertEqual(game.moves[4].variations[0][2].variations[0][5].move, "e6")
        
        XCTAssertEqual(game.moves[4].variations[0][2].variations[1][0].move, "c4")
        
        XCTAssertEqual(game.moves[4].variations[0][3].move, "Nc6")
        XCTAssertEqual(game.moves[4].variations[0][3].variations[0][0].move, "e6")

        XCTAssertEqual(game.moves[5].move, "dxe4")
        
    }
}
