import Foundation
import Testing
@testable import SwiftChessCore

final class GameStateTests: ChessTestBase {

    @Test func testCheckMate() throws {
        try assertGameState(.notStarted)

        try moveAndAssert(notation: "e4", toField: "e4", type: .pawn, color: .white, moveType: .double)
        try assertGameState(.running)
        try moveAndAssert(notation: "f5", toField: "f5", type: .pawn, color: .black, moveType: .double)
        try assertGameState(.running)

        try moveAndAssert(notation: "Bc4", toField: "c4", type: .bishop, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "e6", toField: "e6", type: .pawn, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "h3", toField: "h3", type: .pawn, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "g5", toField: "g5", type: .pawn, color: .black, moveType: .double)
        try assertGameState(.running)

        try moveAndAssert(notation: "Qh5+", toField: "h5", type: .queen, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "Ke7", toField: "e7", type: .king, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "a6", toField: "a6", type: .pawn, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "d3", toField: "d3", type: .pawn, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "b5", toField: "b5", type: .pawn, color: .black, moveType: .double)
        try assertGameState(.running)

        try moveAndAssert(notation: "Bxg5+", toField: "g5", type: .bishop, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "Nf6", toField: "f6", type: .knight, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "Bxf6#", toField: "f6", type: .bishop, color: .white)
        try assertGameState(.whiteWins)
    }

    @Test func testFoolsMate() throws {
        try assertGameState(.notStarted)

        try moveAndAssert(notation: "f3", toField: "f3", type: .pawn, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "g4", toField: "g4", type: .pawn, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "Qh4#", toField: "h4", type: .queen, color: .black)
        try assertGameState(.blackWins)
    }

    @Test func testGrobAttack() throws {
        try assertGameState(.notStarted)

        try moveAndAssert(notation: "g4", toField: "g4", type: .pawn, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "f4", toField: "f4", type: .pawn, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "Qh4#", toField: "h4", type: .queen, color: .black)
        try assertGameState(.blackWins)
    }

    @Test func testScholarsMate() throws {
        try assertGameState(.notStarted)

        try moveAndAssert(notation: "e4", toField: "e4", type: .pawn, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "Bc4", toField: "c4", type: .bishop, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "Nc6", toField: "c6", type: .knight, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "Qh5", toField: "h5", type: .queen, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "Nf6", toField: "f6", type: .knight, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "Qf7#", toField: "f7", type: .queen, color: .white)
        try assertGameState(.whiteWins)
    }

    @Test func testCaroKannSmotheredMate() throws {
        try assertGameState(.notStarted)

        try moveAndAssert(notation: "e4", toField: "e4", type: .pawn, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "c6", toField: "c6", type: .pawn, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "d4", toField: "d4", type: .pawn, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "d5", toField: "d5", type: .pawn, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "Nc3", toField: "c3", type: .knight, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "dxe4", toField: "e4", type: .pawn, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "Nxe4", toField: "e4", type: .knight, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "Nd7", toField: "d7", type: .knight, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "Qe2", toField: "e2", type: .queen, color: .white)
        try assertGameState(.running)
        try moveAndAssert(notation: "Ngf6", toField: "f6", type: .knight, color: .black)
        try assertGameState(.running)

        try moveAndAssert(notation: "Nd6#", toField: "d6", type: .knight, color: .white)
        try assertGameState(.whiteWins)
    }

    @Test func testStalemate() throws {
        loadFen("7k/4NK2/5r2/5BN1/8/8/8/8 w - - 50 115")
        try assertGameState(.running)
        try moveAndAssert(notation: "Kxf6", toField: "f6", type: .king, color: .white)
        try assertGameState(.drawByStalemate)
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

        try assertGameState(.drawByRepetition)
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
            try assertGameState(.drawByInsufficientMaterial, fen: fen)
        }
    }

    @Test func testFiftyMovesRule() throws {
        let moves = loadMoves("1.e4 e6 2.d3 Ne7 3.g3 c5 4.Bg2 Nbc6 5.Be3 b6 6.Ne2 d5 7.O-O d4 8.Bc1 g6 9.Nd2 Bg7 10.f4 f5 11.a3 O-O 12.e5 a5 13.a4 Ba6 14.b3 Rb8 15.Nc4 Qc7 16.Kh1 Nd5 17.Bd2 Rfd8 18.Ng1 Bf8 19.Nf3 Be7 20.h4 h5 21.Qe2 Ncb4 22.Rfc1 Bb7 23.Kh2 Bc6 24.Na3 Ra8 25.Qe1 Rdb8 26.Qg1 Qb7 27.Qf1 Kg7 28.Qh1 Qd7 29.Ne1 Ra7 30.Nf3 Rba8 31.Ne1 Bd8 32.Nf3 Rb8 33.Ne1 Bc7 34.Nf3 Rh8 35.Ng5 Bd8 36.Nf3 Be7 37.Qg1 Bb7 38.Nb5 Raa8 39.Na3 Ba6 40.Qf1 Rab8 41.Nc4 Bd8 42.Qd1 Ne7 43.Nd6 Bc7 44.Qe2 Ng8 45.Ng5 Nh6 46.Bf3 Bd8 47.Nh3 Ng4+ 48.Kg1 Be7 49.Nc4 Nd5 50.Nf2 Bb7 51.Nh3 Bc6 52.Qg2 Rhc8 53.Re1 Rc7 54.Re2 Ra7 55.Ree1 Ra6 56.Re2 Rba8 57.Ree1 R8a7 58.Na3 Ra8 59.Nc4 Nh6 60.Na3 Nf7 61.Nf2 Rd8 62.Nc4 Rb8 63.Nh3 Bd8 64.Na3 Ra7 65.Qh1 Bc7 66.Qg2 Rd8 67.Qh1 Nh6 68.Ng5 Nf7 69.Nh3 Qe8 70.Kh2 Rd7")

        for move in moves {
            if move != moves.first {
                try assertGameState(.running)
            } else {
                try assertGameState(.notStarted)
            }
            try #require(testee).move(move)
        }
        try assertGameState(.drawBy50MoveRule)
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
            try assertGameState(.running, fen: fen)
        }
    }

    @Test func testKNNvK_notInsufficient() throws {
        loadFen("8/5k2/8/3K4/8/8/1N3N2/8 w - - 0 10")
        try assertGameState(.running)
    }

    @Test func testKBBoppositeColors_notInsufficient() throws {
        loadFen("8/2k5/8/4BB2/8/5K2/8/8 w - - 0 10")
        try assertGameState(.running)
    }

    @Test func test50MoveRule_triggersAtLimit() throws {
        loadFen("4k3/8/8/8/8/8/R7/4K3 w - - 100 60")
        try assertGameState(.drawBy50MoveRule)
    }

    @Test func test50MoveRule_notTriggeredOneBefore() throws {
        loadFen("4k3/8/8/8/8/8/R7/4K3 w - - 99 60")
        try assertGameState(.running)
    }

    @Test func testThreefold_samePlacementDifferentSideToMove_notEqual() throws {
        let white = try #require(PositionFactory.loadPosition("4k3/8/8/8/8/8/8/4K3 w - - 0 1"))
        let black = try #require(PositionFactory.loadPosition("4k3/8/8/8/8/8/8/4K3 b - - 0 1"))
        #expect(white.hash != black.hash)
    }

    @Test func testThreefold_castlingRightsLostBreaksRepetition() throws {
        let full = try #require(PositionFactory.loadPosition("r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1"))
        let none = try #require(PositionFactory.loadPosition("r3k2r/8/8/8/8/8/8/R3K2R w - - 0 1"))
        #expect(full.hash != none.hash)
    }

    @Test func testThreefold_countsInitialPosition() throws {
        let game = try #require(testee)
        for notation in ["Nf3", "Nf6", "Ng1", "Ng8", "Nf3", "Nf6", "Ng1", "Ng8"] {
            try game.move(notation)
        }
        try assertGameState(.drawByRepetition)
    }

    @Test func testThreefold_fromLoadedFen_triggers() throws {
        loadFen("7k/8/8/8/3R4/8/8/K7 w - - 0 20")
        let game = try #require(testee)
        for notation in ["Kb1", "Kg8", "Ka1", "Kh8", "Kb1", "Kg8", "Ka1", "Kh8"] {
            try game.move(notation)
        }
        try assertGameState(.drawByRepetition)
    }

    @Test func test50MoveRule_resetByPawnMove() throws {
        loadFen("4k3/p7/8/8/8/8/P7/4K3 w - - 49 30")
        try assertGameState(.running)
        try moveAndAssert(notation: "a4", toField: "a4", type: .pawn, color: .white, moveType: .double)
        try assertGameState(.running)
    }

    @Test func test50MoveRule_resetByCapture() throws {
        loadFen("4k3/8/8/3p4/4P3/8/8/4K3 w - - 49 30")
        try assertGameState(.running)
        try moveAndAssert(notation: "exd5", toField: "d5", type: .pawn, color: .white)
        try assertGameState(.running)
    }

    @Test func testStalemate_queenMoveStalesBlackKingInCorner() throws {
        loadFen("8/8/8/8/8/6K1/7Q/7k w - - 1 10")
        try assertGameState(.running)
        try moveAndAssert(notation: "Qf2", toField: "f2", type: .queen, color: .white)
        try assertGameState(.drawByStalemate)
    }

    @Test func testCaptureCheckerIsLegal() throws {
        loadFen("rnbqkb1r/pp2pppp/2p2N2/8/8/5N2/PPPP1PPP/R1BQKB1R b KQkq - 0 10")
        try assertGameState(.running)
    }

    @Test func testStalemate_twoAdditionalPatterns() throws {
        let stalematePositions = [
            "k7/2Q5/1K6/8/8/8/8/8 b - - 1 10",  // queen + king vs king, black king cornered
            "8/8/8/8/8/2K5/1R6/k7 b - - 1 10"   // rook + king vs king, black king cornered
        ]
        for fen in stalematePositions {
            loadFen(fen)
            try assertGameState(.drawByStalemate, fen: fen)
        }
    }

    @Test func testBlockCheckByInterposition_rookInterposes() throws {
        // White Re2 gives check to black king on e8 along the e-file; black Ra7 interposes on e7
        loadFen("4k3/r7/8/8/8/8/4R3/4K3 b - - 0 1")
        try moveAndAssert(from: "a7", to: "e7", type: .rook, color: .black)
    }

    @Test func testDoubleCheck_kingIsInDoubleCheck() throws {
        // After Nc5-d7: discovered check from Ra5 along rank 5, direct check from Nd7
        loadFen("8/8/8/R1N1k3/8/8/8/7K w - - 0 1")
        try moveAndAssert(from: "c5", to: "d7", type: .knight, color: .white)
        let game = try #require(testee)
        let validator = MoveValidator(game.position)
        #expect(validator.isKingInCheck(), "black king should be in double check after Nc5-d7")
    }

    @Test func test50MoveRule_quietMoveIncrementsHalfmoveClock() throws {
        loadFen("4k3/8/8/8/8/8/R7/4K3 w - - 5 30")
        try moveAndAssert(from: "a2", to: "a4", type: .rook, color: .white)
        let game = try #require(testee)
        #expect(game.position.halfmoveClock == 6, "rook move should increment halfmoveClock from 5 to 6")
    }

    @Test func testCaptureCheckerIsLegal_inGetPossibleMoves() throws {
        // White Nf6 gives check to black king on e8; g7 pawn can capture the checker
        loadFen("rnbqkb1r/pp2pppp/2p2N2/8/8/5N2/PPPP1PPP/R1BQKB1R b KQkq - 0 10")
        let game = try #require(testee)
        let pawn = try #require(game.figures.first { $0.equals(PieceFactory.create("g7", type: .pawn, color: .black)!) })
        let captureMove = try #require(pawn.createMove("f6"))
        #expect(game.getPossibleMoves(forPiece: pawn).contains(captureMove), "g7 pawn can capture the checking knight on f6")
    }
}
