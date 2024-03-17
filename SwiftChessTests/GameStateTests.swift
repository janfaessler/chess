import Foundation
import SwiftChess
import XCTest

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
    
        loadFen("7k/4NK2/5r2/5BN1/8/8/8/8 w - - 50 115")
        
        try assertGameState(.Running)
        
        try moveAndAssert(notation: "Kxf6", toField: "f6", type: .king, color: .white)
        
        try assertGameState(.DrawByStalemate)
    }
    
    func testThreefoldRepetition() throws {
        try moveAndAssert(notation: "Nf3", toField: "f3", type: .knight, color: .white)
        try moveAndAssert(notation: "Nf6", toField: "f6", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Ng1", toField: "g1", type: .knight, color: .white)
        try moveAndAssert(notation: "Ng8", toField: "g8", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Nf3", toField: "f3", type: .knight, color: .white)
        try moveAndAssert(notation: "Nf6", toField: "f6", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Ng1", toField: "g1", type: .knight, color: .white)
        try moveAndAssert(notation: "Ng8", toField: "g8", type: .knight, color: .black)
        
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
    
    func testFiftyMovesRule() throws {
        
        let moves = Pgn.load("1.e4 e6 2.d3 Ne7 3.g3 c5 4.Bg2 Nbc6 5.Be3 b6 6.Ne2 d5 7.O-O d4 8.Bc1 g6 9.Nd2 Bg7 10.f4 f5 11.a3 O-O 12.e5 a5 13.a4 Ba6 14.b3 Rb8 15.Nc4 Qc7 16.Kh1 Nd5 17.Bd2 Rfd8 18.Ng1 Bf8 19.Nf3 Be7 20.h4 h5 21.Qe2 Ncb4 22.Rfc1 Bb7 23.Kh2 Bc6 24.Na3 Ra8 25.Qe1 Rdb8 26.Qg1 Qb7 27.Qf1 Kg7 28.Qh1 Qd7 29.Ne1 Ra7 30.Nf3 Rba8 31.Ne1 Bd8 32.Nf3 Rb8 33.Ne1 Bc7 34.Nf3 Rh8 35.Ng5 Bd8 36.Nf3 Be7 37.Qg1 Bb7 38.Nb5 Raa8 39.Na3 Ba6 40.Qf1 Rab8 41.Nc4 Bd8 42.Qd1 Ne7 43.Nd6 Bc7 44.Qe2 Ng8 45.Ng5 Nh6 46.Bf3 Bd8 47.Nh3 Ng4+ 48.Kg1 Be7 49.Nc4 Nd5 50.Nf2 Bb7 51.Nh3 Bc6 52.Qg2 Rhc8 53.Re1 Rc7 54.Re2 Ra7 55.Ree1 Ra6 56.Re2 Rba8 57.Ree1 R8a7 58.Na3 Ra8 59.Nc4 Nh6 60.Na3 Nf7 61.Nf2 Rd8 62.Nc4 Rb8 63.Nh3 Bd8 64.Na3 Ra7 65.Qh1 Bc7 66.Qg2 Rd8 67.Qh1 Nh6 68.Ng5 Nf7 69.Nh3 Qe8 70.Kh2 Rd7")
        
        for move in moves {
            if move != moves.first {
                try assertGameState(.Running)
            } else {
                try assertGameState(.NotStarted)
            }

            try testee?.move(move)
        }
        
        try assertGameState(.DrawBy50MoveRule)

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
