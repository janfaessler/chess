import XCTest
import SwiftChess

final class RawMovesTests: ChessTestBase {
    
    func testSimplePawnCapture() throws {
        
        try moveAndAssert(from: "e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert(from: "d7", to: "d5", type:.pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("e4", to: "d5", type:.pawn, color: .white)
        
        try assertMoves(["e4", "d5", "exd5"])
        
    }
    
    func testEnPassantLeft() throws {
        
        try moveAndAssert(from: "e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert(from: "a7", to: "a6", type:.pawn, color: .black)
        
        try moveAndAssert(from: "e4", to: "e5", type: .pawn, color: .white)
        try moveAndAssert(from: "d7", to: "d5", type: .pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("e5", to: "d6", type: .pawn, color: .white)
        
        try assertMoves(["e4", "a6", "e5", "d5", "exd6"])

        
    }
    
    func testEnPassanRight() throws {
        
        try moveAndAssert(from: "e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert(from: "a7", to: "a6", type:.pawn, color: .black)
        
        try moveAndAssert(from: "e4", to: "e5", type: .pawn, color: .white)
        try moveAndAssert(from: "f7", to: "f5", type: .pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("e5", to: "f6", type: .pawn, color: .white)
        
        try assertMoves(["e4", "a6", "e5", "f5", "exf6"])
    }
    
    func testEnPassantToPromotion() throws {
        
        try moveAndAssert(from: "e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert(from: "a7", to: "a6", type:.pawn, color: .black)
        
        try moveAndAssert(from: "e4", to: "e5", type: .pawn, color: .white)
        try moveAndAssert(from: "d7", to: "d5", type: .pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("e5", to: "d6", type: .pawn, color: .white)
        try moveAndAssert(from: "b7", to: "b5", type:.pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("d6", to: "e7", type: .pawn, color: .white)
        try moveAndAssert(from: "c7", to: "c5", type:.pawn, color: .black, moveType: .Double)

        try captureAndAssertPromotion("e7", to: "d8", type: .pawn, color: .white)
        
        try assertMoves(["e4", "a6", "e5", "d5", "exd6", "b5", "dxe7", "c5", "exd8=Q"])

    }
    
    func testShortCastle() throws {
    
        try moveAndAssert(from: "e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert(from: "e7", to: "e5", type:.pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(from: "f1", to: "c4", type:.bishop, color: .white)
        try moveAndAssert(from: "f8", to: "c5", type:.bishop, color: .black)
        
        try moveAndAssert(from: "g1", to: "f3", type:.knight, color: .white)
        try moveAndAssert(from: "g8", to: "f6", type:.knight, color: .black)
        
        try moveAndAssert(from: "e1", to: "g1", type:.king, color: .white, moveType: .Castle)
        try moveAndAssert(from: "e8", to: "g8", type:.king, color: .black, moveType: .Castle)
        
        try assertMoves(["e4", "e5", "Bc4", "Bc5", "Nf3", "Nf6", "O-O", "O-O"])

    }
    
    func testLongCastle() throws {
        
        try moveAndAssert(from: "b2", to: "b3", type: .pawn, color: .white)
        try moveAndAssert(from: "b7", to: "b6", type: .pawn, color: .black)
        
        try moveAndAssert(from: "c1", to: "b2", type: .bishop, color: .white)
        try moveAndAssert(from: "c8", to: "b7", type: .bishop, color: .black)
        
        try moveAndAssert(from: "b1", to: "c3", type: .knight, color: .white)
        try moveAndAssert(from: "b8", to: "c6", type: .knight, color: .black)
        
        try moveAndAssert(from: "e2", to: "e3", type: .pawn, color: .white)
        try moveAndAssert(from: "e7", to: "e6", type: .pawn, color: .black)
        
        try moveAndAssert(from: "d1", to: "e2", type: .queen, color: .white)
        try moveAndAssert(from: "d8", to: "e7", type: .queen, color: .black)
        
        try moveAndAssert(from: "e1", to: "c1", type: .king, color: .white, moveType: .Castle)
        try moveAndAssert(from: "e8", to: "c8", type: .king, color: .black, moveType: .Castle)
        
        try assertMoves(["b3", "b6", "Bb2", "Bb7", "Nc3", "Nc6", "e3", "e6", "Qe2", "Qe7", "O-O-O", "O-O-O"])

    }
    
    func testCastleAttemptStartInCheck() throws {
        
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(from: "f2", to: "f3", type: .pawn, color: .white)
        try moveAndAssert(from: "f7", to: "f5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert(from: "d7", to: "d6", type: .pawn, color: .black)
        
        try moveAndAssert(from: "g1", to: "h3", type: .knight, color: .white)
        try moveAndAssert(from: "d8", to: "h4", type: .queen, color: .black)
        
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .Castle)
        
        try assertMoves(["e4", "e5", "f3", "f5", "Bc4", "d6", "Nh3", "Qh4+"])
        
    }
    
    func testCastleAttemptMiddleInCheck() throws {
        
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(from: "g1", to: "f3", type: .knight, color: .white )
        try moveAndAssert(from: "d7", to: "d6", type: .pawn, color: .black)
        
        try moveAndAssert(from: "h2", to: "h3", type: .pawn, color: .white)
        try moveAndAssert(from: "c8", to: "e6", type: .bishop, color: .black)
        
        try moveAndAssert(from: "b1", to: "a3", type: .knight, color: .white)
        try moveAndAssert(from: "f7", to: "f6", type: .pawn, color: .black)
        
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try captureAndAssert("e6", to: "c4", type: .bishop, color: .black)
        
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .Castle)
        
        try assertMoves(["e4", "e5", "Nf3", "d6", "h3", "Be6", "Na3", "f6", "Bc4", "Bxc4"])
    }
    
    
    func testCastleAttemptTargetInCheck() throws {
        
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(from: "f2", to: "f3", type: .pawn, color: .white)
        try moveAndAssert(from: "f8", to: "c5", type: .bishop, color: .black)
        
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert(from: "d7", to: "d6", type: .pawn, color: .black)
        
        try moveAndAssert(from: "g1", to: "e2", type: .knight, color: .white)
        try moveAndAssert(from: "f7", to: "f6", type: .pawn, color: .black)
        
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .Castle)
        
        try assertMoves(["e4", "e5", "f3", "Bc5", "Bc4", "d6", "Ne2", "f6"])

    }
    
    func testCastleWithoutRook() throws {
        
        try moveAndAssert(from: "g1", to: "f3", type: .knight, color: .white)
        try moveAndAssert(from: "b7", to: "b6", type: .pawn, color: .black)
        
        try moveAndAssert(from: "g2", to: "g3", type: .pawn, color: .white)
        try moveAndAssert(from: "c8", to: "b7", type: .bishop, color: .black)
        
        try moveAndAssert(from: "f1", to: "g2", type: .bishop, color: .white)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("f3", to: "e5", type: .knight, color: .white)
        try captureAndAssert("b7", to: "g2", type: .bishop, color: .black)
        
        try captureAndAssert("e5", to: "f7", type: .knight, color: .white)
        try captureAndAssert("g2", to: "h1", type: .bishop, color: .black)
        
        try captureAndAssert("f7", to: "d8", type: .knight, color: .white)
        try captureAndAssert("e8", to: "d8", type: .king, color: .black)
        
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .Castle)
        
        try assertMoves(["Nf3", "b6", "g3", "Bb7", "Bg2", "e5", "Nxe5", "Bxg2", "Nxf7", "Bxh1", "Nxd8", "Kxd8"])
        
    }
    
    func testSimpleCastleWithTryingWrongMoves() throws {
    
        try moveAndAssert(from: "e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert(from: "e7", to: "e5", type:.pawn, color: .black, moveType: .Double)
        
        try moveAndAssertError("f1", to: "c5", type: .bishop, color: .white)
        
        try moveAndAssert(from: "f1", to: "c4", type:.bishop, color: .white)
        try moveAndAssert(from: "f8", to: "b4", type:.bishop, color: .black)
        
        try moveAndAssertError("d2", to: "d3", type: .pawn, color: .white)
        try moveAndAssertError("d2", to: "d4", type: .pawn, color: .white, moveType: .Double)
        
        try moveAndAssert(from: "c2", to: "c3", type:.pawn, color: .white)
        try moveAndAssert(from: "g8", to: "f6", type:.knight, color: .black)
        
        try moveAndAssert(from: "g1", to: "f3", type: .knight, color: .white)
        try moveAndAssert(from: "e8", to: "g8", type:.king, color: .black, moveType: .Castle)
        
        try captureAndAssert("c3", to: "b4", type: .pawn, color: .white)
        try moveAndAssert(from: "f8", to: "e8", type: .rook, color: .black)
        
        try moveAndAssert(from: "e1", to: "g1", type:.king, color: .white, moveType: .Castle)
        try moveAndAssert(from: "g8", to: "h8", type: .king, color: .black)
        
        try moveAndAssert(from: "g1", to: "h1", type: .king, color: .white)
        
        try moveAndAssertError(Move(8, 9,piece: Figure.create("h8", type: .king, color: .black)!, type: MoveType.Normal))
        
        try assertMoves(["e4", "e5", "Bc4", "Bb4", "c3", "Nf6", "Nf3", "O-O", "cxb4", "Re8", "O-O", "Kh8", "Kh1"])
    }
    
    func testRowIntersection() throws {
        
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert(from: "d8", to: "h4", type: .queen, color: .black)
        
        try moveAndAssert(from: "a2", to: "a3", type: .pawn, color: .white)
        
        try captureAndAssertError("h4", to: "c4", type: .queen, color: .black)
        try captureAndAssert("h4", to: "e4", type: .queen, color: .black)
        
        try assertMoves(["e4", "e5", "Bc4", "Qh4", "a3", "Qxe4+"])
    }
    
    func testCheckMate() throws {
        
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert(from: "f7", to: "f5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert(from: "e7", to: "e6", type: .pawn, color: .black)
        
        try moveAndAssert(from: "h2", to: "h3", type: .pawn, color: .white)
        try moveAndAssert(from: "g7", to: "g5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(from: "d1", to: "h5", type: .queen, color: .white)
        
        let king = Figure.create("e8", type: .king, color: .black)!;
        try assertPossibleMoves(forFigure: king, moves: [king.createMove("e7")!])
        
        try moveAndAssert(from: "e8", to: "e7", type: .king, color: .black)
        
        try moveAndAssert(from: "e4", to: "e5", type: .pawn, color: .white)
        
        try assertPossibleMoves(forFigure: Figure.create("e7", type: .king, color: .black)!, moves: [])

        try moveAndAssert(from: "a7", to: "a6", type: .pawn, color: .black)
        
        try moveAndAssert(from: "d2", to: "d3", type: .pawn, color: .white)
        try moveAndAssert(from: "b7", to: "b5", type: .pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("c1", to: "g5", type: .bishop, color: .white)
        try moveAndAssert(from: "g8", to: "f6", type: .knight, color: .black)
        
        try captureAndAssert("g5", to: "f6", type: .bishop, color: .white)
        
        try assertMoves(["e4", "f5", "Bc4", "e6", "h3", "g5", "Qh5+", "Ke7", "e5", "a6","d3","b5", "Bxg5+", "Nf6", "Bxf6+"])
        
    }

}
