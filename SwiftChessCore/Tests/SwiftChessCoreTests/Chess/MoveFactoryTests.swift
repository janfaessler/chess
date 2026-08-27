import Testing
@testable import SwiftChessCore

struct MoveFactoryTests {

    @Test func testPawnMoves() throws {
        var board = try PositionFactory.startingPosition()
        try assertMove("e4",   board: &board, field: "e4", type: .pawn, color: .white, moveType: .double)
        try assertMove("e5",   board: &board, field: "e5", type: .pawn, color: .black, moveType: .double)
        try assertMove("d4",   board: &board, field: "d4", type: .pawn, color: .white, moveType: .double)
        try assertMove("exd4", board: &board, field: "d4", type: .pawn, color: .black)
        try assertMove("e5",   board: &board, field: "e5", type: .pawn, color: .white)
        try assertMove("f5",   board: &board, field: "f5", type: .pawn, color: .black, moveType: .double)
        try assertMove("exf6", board: &board, field: "f6", type: .pawn, color: .white)
        try assertMove("d3",   board: &board, field: "d3", type: .pawn, color: .black)
        try assertMove("fxg7", board: &board, field: "g7", type: .pawn, color: .white)
        try assertMove("dxc2", board: &board, field: "c2", type: .pawn, color: .black)
        try assertMove("gxh8=Q", board: &board, field: "h8", type: .pawn, color: .white, moveType: .promotion)
        try assertMove("cxb1=Q", board: &board, field: "b1", type: .pawn, color: .black, moveType: .promotion)
    }

    @Test func testPieceMoves() throws {
        var board = try PositionFactory.startingPosition()
        try assertMove("e4",    board: &board, field: "e4",  type: .pawn,   color: .white, moveType: .double)
        try assertMove("e5",    board: &board, field: "e5",  type: .pawn,   color: .black, moveType: .double)
        try assertMove("Nc3",   board: &board, field: "c3",  type: .knight, color: .white)
        try assertMove("Nc6",   board: &board, field: "c6",  type: .knight, color: .black)
        try assertMove("Bc4",   board: &board, field: "c4",  type: .bishop, color: .white)
        try assertMove("Bc5",   board: &board, field: "c5",  type: .bishop, color: .black)
        try assertMove("Qg4",   board: &board, field: "g4",  type: .queen,  color: .white)
        try assertMove("Qf6",   board: &board, field: "f6",  type: .queen,  color: .black)
        try assertMove("Nd5",   board: &board, field: "d5",  type: .knight, color: .white)
        try assertMove("Qxf2+", board: &board, field: "f2",  type: .queen,  color: .black)
        try assertMove("Kd1",   board: &board, field: "d1",  type: .king,   color: .white)
        try assertMove("Bb6",   board: &board, field: "b6",  type: .bishop, color: .black)
        try assertMove("Nh3",   board: &board, field: "h3",  type: .knight, color: .white)
        try assertMove("d6",    board: &board, field: "d6",  type: .pawn,   color: .black)
        try assertMove("Nxf2",  board: &board, field: "f2",  type: .knight, color: .white)
        try assertMove("Bxg4+", board: &board, field: "g4",  type: .bishop, color: .black)
        try assertMove("Nxg4",  board: &board, field: "g4",  type: .knight, color: .white)
    }

    @Test func testShortCastle() throws {
        var board = try PositionFactory.startingPosition()
        try assertMove("e4",  board: &board, field: "e4",  type: .pawn,   color: .white, moveType: .double)
        try assertMove("e5",  board: &board, field: "e5",  type: .pawn,   color: .black, moveType: .double)
        try assertMove("Bc4", board: &board, field: "c4",  type: .bishop, color: .white)
        try assertMove("Bc5", board: &board, field: "c5",  type: .bishop, color: .black)
        try assertMove("Nf3", board: &board, field: "f3",  type: .knight, color: .white)
        try assertMove("Nf6", board: &board, field: "f6",  type: .knight, color: .black)
        try assertMove("O-O", board: &board, field: "g1",  type: .king,   color: .white, moveType: .castle)
        try assertMove("O-O", board: &board, field: "g8",  type: .king,   color: .black, moveType: .castle)
    }

    @Test func testLongCastle() throws {
        var board = try PositionFactory.startingPosition()
        try assertMove("b3",    board: &board, field: "b3",  type: .pawn,   color: .white)
        try assertMove("b6",    board: &board, field: "b6",  type: .pawn,   color: .black)
        try assertMove("Bb2",   board: &board, field: "b2",  type: .bishop, color: .white)
        try assertMove("Bb7",   board: &board, field: "b7",  type: .bishop, color: .black)
        try assertMove("Nc3",   board: &board, field: "c3",  type: .knight, color: .white)
        try assertMove("Nc6",   board: &board, field: "c6",  type: .knight, color: .black)
        try assertMove("e3",    board: &board, field: "e3",  type: .pawn,   color: .white)
        try assertMove("e6",    board: &board, field: "e6",  type: .pawn,   color: .black)
        try assertMove("Qe2",   board: &board, field: "e2",  type: .queen,  color: .white)
        try assertMove("Qe7",   board: &board, field: "e7",  type: .queen,  color: .black)
        try assertMove("O-O-O", board: &board, field: "c1",  type: .king,   color: .white, moveType: .castle)
        try assertMove("O-O-O", board: &board, field: "c8",  type: .king,   color: .black, moveType: .castle)
    }

    @Test func testUncertainKnightMoves() throws {
        var board = try PositionFactory.startingPosition()
        try assertMove("e4",   board: &board, field: "e4",  type: .pawn,   color: .white, moveType: .double)
        try assertMove("c6",   board: &board, field: "c6",  type: .pawn,   color: .black)
        try assertMove("d3",   board: &board, field: "d3",  type: .pawn,   color: .white)
        try assertMove("d5",   board: &board, field: "d5",  type: .pawn,   color: .black, moveType: .double)
        try assertMove("Nd2",  board: &board, field: "d2",  type: .knight, color: .white)
        try assertMove("Nd7",  board: &board, field: "d7",  type: .knight, color: .black)
        try assertMove("Ngf3", board: &board, field: "f3",  type: .knight, color: .white)
        try assertMove("Ngf6", board: &board, field: "f6",  type: .knight, color: .black)
        try assertMove("Nb3",  board: &board, field: "b3",  type: .knight, color: .white)
        try assertMove("Nb6",  board: &board, field: "b6",  type: .knight, color: .black)
        try assertMove("Nfd2", board: &board, field: "d2",  type: .knight, color: .white)
        try assertMove("Ng4",  board: &board, field: "g4",  type: .knight, color: .black)
        try assertMove("Nc4",  board: &board, field: "c4",  type: .knight, color: .white)
        try assertMove("Nf6",  board: &board, field: "f6",  type: .knight, color: .black)
        try assertMove("Nca5", board: &board, field: "a5",  type: .knight, color: .white)
        try assertMove("Ng4",  board: &board, field: "g4",  type: .knight, color: .black)
        try assertMove("Nxb7", board: &board, field: "b7",  type: .knight, color: .white)
        try assertMove("Nf6",  board: &board, field: "f6",  type: .knight, color: .black)
        try assertMove("N7c5", board: &board, field: "c5",  type: .knight, color: .white)
        try assertMove("Ng4",  board: &board, field: "g4",  type: .knight, color: .black)
        try assertMove("Nd2",  board: &board, field: "d2",  type: .knight, color: .white)
    }

    @Test func testUncertainRookMoves() throws {
        var board = try PositionFactory.startingPosition()
        try assertMove("e4",   board: &board, field: "e4",  type: .pawn,   color: .white, moveType: .double)
        try assertMove("e5",   board: &board, field: "e5",  type: .pawn,   color: .black, moveType: .double)
        try assertMove("Nf3",  board: &board, field: "f3",  type: .knight, color: .white)
        try assertMove("Nf6",  board: &board, field: "f6",  type: .knight, color: .black)
        try assertMove("Bc4",  board: &board, field: "c4",  type: .bishop, color: .white)
        try assertMove("Bc5",  board: &board, field: "c5",  type: .bishop, color: .black)
        try assertMove("O-O",  board: &board, field: "g1",  type: .king,   color: .white, moveType: .castle)
        try assertMove("O-O",  board: &board, field: "g8",  type: .king,   color: .black, moveType: .castle)
        try assertMove("Nc3",  board: &board, field: "c3",  type: .knight, color: .white)
        try assertMove("Nc6",  board: &board, field: "c6",  type: .knight, color: .black)
        try assertMove("d3",   board: &board, field: "d3",  type: .pawn,   color: .white)
        try assertMove("d6",   board: &board, field: "d6",  type: .pawn,   color: .black)
        try assertMove("Be3",  board: &board, field: "e3",  type: .bishop, color: .white)
        try assertMove("Be6",  board: &board, field: "e6",  type: .bishop, color: .black)
        try assertMove("Qd2",  board: &board, field: "d2",  type: .queen,  color: .white)
        try assertMove("Qd7",  board: &board, field: "d7",  type: .queen,  color: .black)
        try assertMove("Rfd1", board: &board, field: "d1",  type: .rook,   color: .white)
        try assertMove("Rfe8", board: &board, field: "e8",  type: .rook,   color: .black)
        try assertMove("Rac1", board: &board, field: "c1",  type: .rook,   color: .white)
        try assertMove("Rac8", board: &board, field: "c8",  type: .rook,   color: .black)
    }

    @Test func testUncertainPawnMove() throws {
        var board = try PositionFactory.startingPosition()
        try assertMove("e4",   board: &board, field: "e4",  type: .pawn,   color: .white, moveType: .double)
        try assertMove("c6",   board: &board, field: "c6",  type: .pawn,   color: .black)
        try assertMove("d4",   board: &board, field: "d4",  type: .pawn,   color: .white, moveType: .double)
        try assertMove("d5",   board: &board, field: "d5",  type: .pawn,   color: .black, moveType: .double)
        try assertMove("Nc3",  board: &board, field: "c3",  type: .knight, color: .white)
        try assertMove("dxe4", board: &board, field: "e4",  type: .pawn,   color: .black)
        try assertMove("Nxe4", board: &board, field: "e4",  type: .knight, color: .white)
        try assertMove("Nf6",  board: &board, field: "f6",  type: .knight, color: .black)
        try assertMove("Nxf6+", board: &board, field: "f6", type: .knight, color: .white)
        try assertMove("exf6", board: &board, field: "f6",  type: .pawn,   color: .black)

        #expect(board.isEmpty(atRow: 5, atFile: 6))
        #expect(!board.isEmpty(atRow: 7, atFile: 6))
    }

    @Test func testMalformedInputReturnsNilInsteadOfCrashing() {
        let board = try! PositionFactory.startingPosition()
        #expect(MoveFactory.create("",  position: board) == nil)
        #expect(MoveFactory.create("N", position: board) == nil)
        #expect(MoveFactory.create("R", position: board) == nil)
        #expect(MoveFactory.create("x", position: board) == nil)
        #expect(MoveFactory.create("=", position: board) == nil)
        #expect(MoveFactory.create("Z9", position: board) == nil)
    }

    private func assertMove(
        _ moveName: String,
        board: inout Position,
        field: String,
        type: PieceType,
        color: PieceColor,
        moveType: MoveType = .normal,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let move = try #require(MoveFactory.create(moveName, position: board), "move \(moveName) could not be created", sourceLocation: sourceLocation)
        #expect(move.piece.type == type, "\(moveName): piece type mismatch", sourceLocation: sourceLocation)
        #expect(move.piece.color == color, "\(moveName): piece color mismatch", sourceLocation: sourceLocation)
        #expect(move.squareInfo == field, "\(moveName): target square mismatch", sourceLocation: sourceLocation)
        #expect(move.type == moveType, "\(moveName): move type mismatch", sourceLocation: sourceLocation)
        board = board.applying(move)
    }
}
