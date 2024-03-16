import Foundation
import SwiftChess

final class GameStateTests : ChessTestBase {
    
    func testCheckMate() throws {
    
        try assertGameState(.NotStarted)
        
        try moveAndAssert(notation: "e4", toField: "e4", type: .pawn, color: .white, moveType: .Double)
        try assertGameState(.Running)
        try moveAndAssert(notation: "f5", toField: "f5", type: .pawn, color: .black, moveType: .Double)
        try assertGameState(.Running)

        try moveAndAssert(notation: "Bc4", toField: "c4", type: .bishop, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "e6", toField: "e6", type: .pawn, color: .black)
        try assertGameState(.Running)

        try moveAndAssert(notation: "h3", toField: "h3", type: .pawn, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "g5", toField: "g5", type: .pawn, color: .black, moveType: .Double)
        try assertGameState(.Running)

        try moveAndAssert(notation: "Qh5+", toField: "h5", type: .queen, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "Ke7", toField: "e7", type: .king, color: .black)
        try assertGameState(.Running)

        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "a6", toField: "a6", type: .pawn, color: .black)
        try assertGameState(.Running)

        try moveAndAssert(notation: "d3", toField: "d3", type: .pawn, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "b5", toField: "b5", type: .pawn, color: .black, moveType: .Double)
        try assertGameState(.Running)

        try moveAndAssert(notation: "Bxg5+", toField: "g5", type: .bishop, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "Nf6", toField: "f6", type: .knight, color: .black)
        try assertGameState(.Running)

        try moveAndAssert(notation: "Bxf6#", toField: "f6", type: .bishop, color: .white)
        try assertGameState(.WhiteWins)
        
    }
    
    func testFoolsMate() throws {
        
        try assertGameState(.NotStarted)
        
        try moveAndAssert(notation: "f3", toField: "f3", type: .pawn, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .black)
        try assertGameState(.Running)
        
        try moveAndAssert(notation: "g4", toField: "g4", type: .pawn, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "Qh4#", toField: "h4", type: .queen, color: .black)
        try assertGameState(.BlackWins)
    }
    
    func testGropsAttack() throws {
        try assertGameState(.NotStarted)
        
        try moveAndAssert(notation: "g4", toField: "g4", type: .pawn, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .black)
        try assertGameState(.Running)
        
        try moveAndAssert(notation: "f4", toField: "f4", type: .pawn, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "Qh4#", toField: "h4", type: .queen, color: .black)
        try assertGameState(.BlackWins)
    }
    
    func testScholarsMate() throws {
        try assertGameState(.NotStarted)
        
        try moveAndAssert(notation: "e4", toField: "e4", type: .pawn, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .black)
        try assertGameState(.Running)

        try moveAndAssert(notation: "Bc4", toField: "c4", type: .bishop, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "Nc6", toField: "c6", type: .knight, color: .black)
        try assertGameState(.Running)

        try moveAndAssert(notation: "Qh5", toField: "h5", type: .queen, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "Nf6", toField: "f6", type: .knight, color: .black)
        try assertGameState(.Running)

        try moveAndAssert(notation: "Qf7#", toField: "f7", type: .queen, color: .white)
        try assertGameState(.WhiteWins)
    }
    
    func testCaroKannSmotheredMate() throws {
        
        try assertGameState(.NotStarted)
        
        try moveAndAssert(notation: "e4", toField: "e4", type: .pawn, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "c6", toField: "c6", type: .pawn, color: .black)
        try assertGameState(.Running)

        try moveAndAssert(notation: "d4", toField: "d4", type: .pawn, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "d5", toField: "d5", type: .pawn, color: .black)
        try assertGameState(.Running)

        try moveAndAssert(notation: "Nc3", toField: "c3", type: .knight, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "dxe4", toField: "e4", type: .pawn, color: .black)
        try assertGameState(.Running)

        try moveAndAssert(notation: "Nxe4", toField: "e4", type: .knight, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "Nd7", toField: "d7", type: .knight, color: .black)
        try assertGameState(.Running)

        try moveAndAssert(notation: "Qe2", toField: "e2", type: .queen, color: .white)
        try assertGameState(.Running)
        try moveAndAssert(notation: "Ngf6", toField: "f6", type: .knight, color: .black)
        try assertGameState(.Running)

        try moveAndAssert(notation: "Nd6#", toField: "d6", type: .knight, color: .white)
        try assertGameState(.WhiteWins)

    }
    
    func testStalemate() throws  {
    
        loadFen("7k/4NK2/5r2/5BN1/8/8/8/8 w - - 103 115")
        
        try assertGameState(.Running)
        
        try moveAndAssert(notation: "Kxf6", toField: "f6", type: .king, color: .white)
        
        try assertGameState(.DrawByStalemate)
    }
    
    func testThreefoldRepetition() throws {
        try moveAndAssert(notation: "Nf3", toField: "f3", type: .knight, color: .white)
        try moveAndAssert(notation: "Nf6", toField: "f6", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Nd4", toField: "d4", type: .knight, color: .white)
        try moveAndAssert(notation: "Nd5", toField: "d5", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Nb3", toField: "b3", type: .knight, color: .white)
        try moveAndAssert(notation: "Nb6", toField: "b6", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Nc3", toField: "c3", type: .knight, color: .white)
        try moveAndAssert(notation: "Nc6", toField: "c6", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Ne4", toField: "e4", type: .knight, color: .white)
        try moveAndAssert(notation: "Ne5", toField: "e5", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Ng5", toField: "g5", type: .knight, color: .white)
        try moveAndAssert(notation: "Ng4", toField: "g4", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Nf3", toField: "f3", type: .knight, color: .white)
        try moveAndAssert(notation: "Nf6", toField: "f6", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Ng1", toField: "g1", type: .knight, color: .white)
        try moveAndAssert(notation: "Ng8", toField: "g8", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Nc5", toField: "c5", type: .knight, color: .white)
        try moveAndAssert(notation: "Nc4", toField: "c4", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Na4", toField: "a4", type: .knight, color: .white)
        try moveAndAssert(notation: "Na5", toField: "a5", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Nc3", toField: "c3", type: .knight, color: .white)
        try moveAndAssert(notation: "Nc6", toField: "c6", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Nb1", toField: "b1", type: .knight, color: .white)
        try moveAndAssert(notation: "Nb8", toField: "b8", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Nf3", toField: "f3", type: .knight, color: .white)
        
        try assertGameState(.DrawByRepetition)

        
    }
    
    func testDrawByInsufficientMaterial() throws {
        
        let drawFens = [
            "8/5k2/8/3K4/8/8/8/8 w - - 0 1",
            "8/5k2/8/3K1b2/8/8/8/8 w - - 0 1",
            "8/5k2/8/3K4/8/2B5/8/8 w - - 0 1",
            "8/5k2/8/3K4/6n1/8/8/8 w - - 0 1",
            "8/5k2/8/3K4/8/8/5N2/8 w - - 0 1",
            "8/5k2/b7/3K4/6B1/8/8/8 w - - 0 1"
        ]
        
        for fen in drawFens {
            loadFen(fen)
            try assertGameState(.DrawByInsufficientMaterial, fen: fen)
        }
    }
    
    func testNoDraw() throws {
        let notADrawFen = [
            "8/5k2/b7/3K4/7B/8/8/8 w - - 0 10",
            "8/5k2/8/3K1b2/8/8/8/6r1 w - - 0 10",
            "8/5k2/8/3K1b2/8/8/1n6/8 w - - 0 10",
        ]
        
        for fen in notADrawFen {
            loadFen(fen)
            try assertGameState(.Running, fen: fen)
        }
    }
}
