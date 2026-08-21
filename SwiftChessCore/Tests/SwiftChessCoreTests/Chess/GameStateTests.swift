import Foundation
import Testing
@testable import SwiftChessCore

final class GameStateTests: ChessTestBase {

    @Test func testCheckMate() throws {
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

    @Test func testFoolsMate() throws {
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

    @Test func testGropsAttack() throws {
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

    @Test func testScholarsMate() throws {
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

    @Test func testCaroKannSmotheredMate() throws {
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

    @Test func testStalemate() throws {
        loadFen("7k/4NK2/5r2/5BN1/8/8/8/8 w - - 50 115")
        try assertGameState(.Running)
        try moveAndAssert(notation: "Kxf6", toField: "f6", type: .king, color: .white)
        try assertGameState(.DrawByStalemate)
    }

    @Test func testThreefoldRepetition() throws {
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

    @Test func testDrawByInsufficientMaterial() throws {
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

    @Test func testFiftyMovesRule() throws {
        let moves = loadMoves("1.e4 e6 2.d3 Ne7 3.g3 c5 4.Bg2 Nbc6 5.Be3 b6 6.Ne2 d5 7.O-O d4 8.Bc1 g6 9.Nd2 Bg7 10.f4 f5 11.a3 O-O 12.e5 a5 13.a4 Ba6 14.b3 Rb8 15.Nc4 Qc7 16.Kh1 Nd5 17.Bd2 Rfd8 18.Ng1 Bf8 19.Nf3 Be7 20.h4 h5 21.Qe2 Ncb4 22.Rfc1 Bb7 23.Kh2 Bc6 24.Na3 Ra8 25.Qe1 Rdb8 26.Qg1 Qb7 27.Qf1 Kg7 28.Qh1 Qd7 29.Ne1 Ra7 30.Nf3 Rba8 31.Ne1 Bd8 32.Nf3 Rb8 33.Ne1 Bc7 34.Nf3 Rh8 35.Ng5 Bd8 36.Nf3 Be7 37.Qg1 Bb7 38.Nb5 Raa8 39.Na3 Ba6 40.Qf1 Rab8 41.Nc4 Bd8 42.Qd1 Ne7 43.Nd6 Bc7 44.Qe2 Ng8 45.Ng5 Nh6 46.Bf3 Bd8 47.Nh3 Ng4+ 48.Kg1 Be7 49.Nc4 Nd5 50.Nf2 Bb7 51.Nh3 Bc6 52.Qg2 Rhc8 53.Re1 Rc7 54.Re2 Ra7 55.Ree1 Ra6 56.Re2 Rba8 57.Ree1 R8a7 58.Na3 Ra8 59.Nc4 Nh6 60.Na3 Nf7 61.Nf2 Rd8 62.Nc4 Rb8 63.Nh3 Bd8 64.Na3 Ra7 65.Qh1 Bc7 66.Qg2 Rd8 67.Qh1 Nh6 68.Ng5 Nf7 69.Nh3 Qe8 70.Kh2 Rd7")

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

    @Test func testNoDraw() throws {
        let notADrawFen = [
            "8/5k2/b7/3K4/7B/8/8/8 w - - 0 10",
            "8/5k2/8/3K1b2/8/8/8/6r1 w - - 0 10",
            "8/5k2/8/3K1b2/8/8/1n6/8 w - - 0 10",
            "8/2k5/8/4BB2/8/5K2/8/8 w - - 0 10"
        ]
        for fen in notADrawFen {
            loadFen(fen)
            try assertGameState(.Running, fen: fen)
        }
    }

    @Test func testKNNvK_notInsufficient() throws {
        loadFen("8/5k2/8/3K4/8/8/1N3N2/8 w - - 0 10")
        try assertGameState(.Running)
    }

    @Test func testKBBoppositeColors_notInsufficient() throws {
        loadFen("8/2k5/8/4BB2/8/5K2/8/8 w - - 0 10")
        try assertGameState(.Running)
    }

    @Test func test50MoveRule_triggersAtLimit() throws {
        loadFen("4k3/8/8/8/8/8/R7/4K3 w - - 100 60")
        try assertGameState(.DrawBy50MoveRule)
    }

    @Test func test50MoveRule_notTriggeredOneBefore() throws {
        loadFen("4k3/8/8/8/8/8/R7/4K3 w - - 99 60")
        try assertGameState(.Running)
    }

    @Test func testThreefold_samePlacementDifferentSideToMove_notEqual() throws {
        let white = try #require(PositionFactory.loadPosition("4k3/8/8/8/8/8/8/4K3 w - - 0 1"))
        let black = try #require(PositionFactory.loadPosition("4k3/8/8/8/8/8/8/4K3 b - - 0 1"))
        #expect(white.getHash() != black.getHash())
    }

    @Test func testThreefold_castlingRightsLostBreaksRepetition() throws {
        let full = try #require(PositionFactory.loadPosition("r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1"))
        let none = try #require(PositionFactory.loadPosition("r3k2r/8/8/8/8/8/8/R3K2R w - - 0 1"))
        #expect(full.getHash() != none.getHash())
    }

    @Test func testThreefold_countsInitialPosition() throws {
        for notation in ["Nf3", "Nf6", "Ng1", "Ng8", "Nf3", "Nf6", "Ng1", "Ng8"] {
            try testee?.move(notation)
        }
        try assertGameState(.DrawByRepetition)
    }

    @Test func testThreefold_fromLoadedFen_triggers() throws {
        loadFen("7k/8/8/8/3R4/8/8/K7 w - - 0 20")
        for notation in ["Kb1", "Kg8", "Ka1", "Kh8", "Kb1", "Kg8", "Ka1", "Kh8"] {
            try testee?.move(notation)
        }
        try assertGameState(.DrawByRepetition)
    }
}
