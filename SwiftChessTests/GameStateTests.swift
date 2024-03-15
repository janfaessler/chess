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
}
