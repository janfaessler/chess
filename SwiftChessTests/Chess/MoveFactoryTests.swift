import XCTest
import SwiftChess

final class MoveFactoryTests: XCTestCase {

    private var boardCache:Position?
    
    override func setUpWithError() throws {
        boardCache = PositionFactory.startingPosition();
    }

    func testPawnMoves() throws {
        try assertMove("e4", field: "e4", type: .pawn, color: .white, moveType: .Double)
        try assertMove("e5", field: "e5", type: .pawn, color: .black, moveType: .Double)
        try assertMove("d4", field: "d4", type: .pawn, color: .white, moveType: .Double)
        try assertMove("exd4", field: "d4", type: .pawn, color: .black)
        try assertMove("e5", field: "e5", type: .pawn, color: .white)
        try assertMove("f5", field: "f5", type: .pawn, color: .black, moveType: .Double)
        try assertMove("exf6", field: "f6", type: .pawn, color: .white)
        try assertMove("d3", field: "d3", type: .pawn, color: .black)
        try assertMove("fxg7", field: "g7", type: .pawn, color: .white)
        try assertMove("dxc2", field: "c2", type: .pawn, color: .black)
        try assertMove("gxh8=Q", field: "h8", type: .pawn, color: .white, moveType: .Promotion)
        try assertMove("cxb1=Q", field: "b1", type: .pawn, color: .black, moveType: .Promotion)
    }
    
    func testPieceMoves() throws {
        try assertMove("e4", field: "e4", type: .pawn, color: .white, moveType: .Double)
        try assertMove("e5", field: "e5", type: .pawn, color: .black, moveType: .Double)
        try assertMove("Nc3", field: "c3", type: .knight, color: .white)
        try assertMove("Nc6", field: "c6", type: .knight, color: .black)
        try assertMove("Bc4", field: "c4", type: .bishop, color: .white)
        try assertMove("Bc5", field: "c5", type: .bishop, color: .black)
        try assertMove("Qg4", field: "g4", type: .queen, color: .white)
        try assertMove("Qf6", field: "f6", type: .queen, color: .black)
        try assertMove("Nd5", field: "d5", type: .knight, color: .white)
        try assertMove("Qxf2+", field: "f2", type: .queen, color: .black)
        try assertMove("Kd1", field: "d1", type: .king, color: .white)
        try assertMove("Bb6", field: "b6", type: .bishop, color: .black)
        try assertMove("Nh3", field: "h3", type: .knight, color: .white)
        try assertMove("d6", field: "d6", type: .pawn, color: .black)
        try assertMove("Nxf2", field: "f2", type: .knight, color: .white)
        try assertMove("Bxg4+", field: "g4", type: .bishop, color: .black)
        try assertMove("Nxg4", field: "g4", type: .knight, color: .white)
    }
    
    func testShortCastle() throws {
    
        try assertMove("e4", field: "e4", type:.pawn, color: .white, moveType: .Double)
        try assertMove("e5", field: "e5", type:.pawn, color: .black, moveType: .Double)
        
        try assertMove("Bc4", field: "c4", type:.bishop, color: .white)
        try assertMove("Bc5", field: "c5", type:.bishop, color: .black)
        
        try assertMove("Nf3", field: "f3", type:.knight, color: .white)
        try assertMove("Nf6", field: "f6", type:.knight, color: .black)
        
        try assertMove("O-O", field: "g1", type:.king, color: .white, moveType: .Castle)
        try assertMove("O-O", field: "g8", type:.king, color: .black, moveType: .Castle)
        
    }
    
    func testLongCastle() throws {
        
        try assertMove("b3", field: "b3", type: .pawn, color: .white)
        try assertMove("b6", field: "b6", type: .pawn, color: .black)
        
        try assertMove("Bb2", field: "b2", type: .bishop, color: .white)
        try assertMove("Bb7", field: "b7", type: .bishop, color: .black)
        
        try assertMove("Nc3", field: "c3", type: .knight, color: .white)
        try assertMove("Nc6", field: "c6", type: .knight, color: .black)
        
        try assertMove("e3", field: "e3", type: .pawn, color: .white)
        try assertMove("e6", field: "e6", type: .pawn, color: .black)
        
        try assertMove("Qe2", field: "e2", type: .queen, color: .white)
        try assertMove("Qe7", field: "e7", type: .queen, color: .black)
        
        try assertMove("O-O-O", field: "c1", type: .king, color: .white, moveType: .Castle)
        try assertMove("O-O-O", field: "c8", type: .king, color: .black, moveType: .Castle)
        
    }
    
    func testUncertainKnightMoves() throws {
        try assertMove("e4", field: "e4", type: .pawn, color: .white, moveType: .Double)
        try assertMove("c6", field: "c6", type: .pawn, color: .black)
        
        try assertMove("d3", field: "d3", type: .pawn, color: .white)
        try assertMove("d5", field: "d5", type: .pawn, color: .black, moveType: .Double)
        
        try assertMove("Nd2", field: "d2", type: .knight, color: .white)
        try assertMove("Nd7", field: "d7", type: .knight, color: .black)
        
        try assertMove("Ngf3", field: "f3", type: .knight, color: .white)
        try assertMove("Ngf6", field: "f6", type: .knight, color: .black)
        
        try assertMove("Nb3", field: "b3", type: .knight, color: .white)
        try assertMove("Nb6", field: "b6", type: .knight, color: .black)
        
        try assertMove("Nfd2", field: "d2", type: .knight, color: .white)
        try assertMove("Ng4", field: "g4", type: .knight, color: .black)

        try assertMove("Nc4", field: "c4", type: .knight, color: .white)
        try assertMove("Nf6", field: "f6", type: .knight, color: .black)
        
        try assertMove("Nca5", field: "a5", type: .knight, color: .white)
        try assertMove("Ng4", field: "g4", type: .knight, color: .black)

        try assertMove("Nxb7", field: "b7", type: .knight, color: .white)
        try assertMove("Nf6", field: "f6", type: .knight, color: .black)
        
        try assertMove("N7c5", field: "c5", type: .knight, color: .white)
        try assertMove("Ng4", field: "g4", type: .knight, color: .black)
        
        try assertMove("Nd2", field: "d2", type: .knight, color: .white)
    }
    
    func testUncertainRookMoves() throws {
        try assertMove("e4", field: "e4", type: .pawn, color: .white, moveType: .Double)
        try assertMove("e5", field: "e5", type: .pawn, color: .black, moveType: .Double)
    
        try assertMove("Nf3", field: "f3", type: .knight, color: .white)
        try assertMove("Nf6" ,field: "f6", type: .knight, color: .black)
    
        try assertMove("Bc4", field: "c4", type: .bishop, color: .white)
        try assertMove("Bc5", field: "c5", type: .bishop, color: .black)
    
        try assertMove("O-O", field: "g1", type: .king, color: .white, moveType: .Castle)
        try assertMove("O-O", field: "g8", type: .king, color: .black, moveType: .Castle)
        
        try assertMove("Nc3", field: "c3", type: .knight, color: .white)
        try assertMove("Nc6", field: "c6", type: .knight, color: .black)
        
        try assertMove("d3", field: "d3", type: .pawn, color: .white)
        try assertMove("d6", field: "d6", type: .pawn, color: .black)
        
        try assertMove("Be3", field: "e3", type: .bishop, color: .white)
        try assertMove("Be6", field: "e6", type: .bishop, color: .black)
        
        try assertMove("Qd2", field: "d2", type: .queen, color: .white)
        try assertMove("Qd7", field: "d7", type: .queen, color: .black)
        
        try assertMove("Rfd1", field: "d1", type: .rook, color: .white)
        try assertMove("Rfe8", field: "e8", type: .rook, color: .black)
        
        try assertMove("Rac1", field: "c1", type: .rook, color: .white)
        try assertMove("Rac8", field: "c8", type: .rook, color: .black)
    
    }
    
    public func testUncertainPawnMove() throws {

        try assertMove("e4", field: "e4", type: .pawn, color: .white, moveType: .Double)
        try assertMove("c6", field: "c6", type: .pawn, color: .black)
        
        try assertMove("d4", field: "d4", type: .pawn, color: .white, moveType: .Double)
        try assertMove("d5", field: "d5", type: .pawn, color: .black, moveType: .Double)
        
        try assertMove("Nc3", field: "c3", type: .knight, color: .white)
        try assertMove("dxe4", field: "e4", type: .pawn, color: .black)
        
        try assertMove("Nxe4", field: "e4", type: .knight, color: .white)
        try assertMove("Nf6", field: "f6", type: .knight, color: .black)
        
        try assertMove("Nxf6+", field: "f6", type: .knight, color: .white)
        try assertMove("exf6", field: "f6", type: .pawn, color: .black)
        
        XCTAssertTrue(try XCTUnwrap(boardCache).isEmpty(atRow: 5, atFile: 6))
        XCTAssertFalse(try XCTUnwrap(boardCache).isEmpty(atRow: 7, atFile: 6))

    }
    

    private func assertMove(
        _ moveName:String,
        field:String,
        type:PieceType,
        color:PieceColor,
        moveType:MoveType = .Normal,
        message: (Move?) -> String = { $0 == nil ? "Move not found ": "Move[\($0!.getFieldInfo()), \($0!.getPiece().getType()),\($0!.getPiece().getColor()), \($0!.getType())]  is the wrong move" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let cache = try XCTUnwrap(boardCache)
        let move:Move? = MoveFactory.create(moveName, position:cache);
        
        guard move == nil || move?.getPiece().getType() != type || move?.getPiece().getColor() != color || move?.getFieldInfo() != field || move?.getType() != moveType else {
            try updateBoardCache(move!, isCapture: moveName.contains("x"))
            return
        }
        
        XCTFail(message(move), file: file, line: line)
    }
    
    private func updateBoardCache(_ move:Move, isCapture:Bool) throws {
        let cache = try XCTUnwrap(boardCache)
        var figures:[any ChessFigure] = cache.getFigures()
        let fig = figures.first(where: { $0.equals(move.getPiece())})!
        let capturedPiece = cache.get(atRow: move.getRow(), atFile: move.getFile())
        figures.removeAll(where: { $0.equals(move.getPiece()) || capturedPiece?.equals($0) == true })
        fig.move(row: move.getRow(), file: move.getFile())
        figures.append(fig)
        if move.getType() == .Castle {
            if move.getFile() == King.CastleQueensidePosition{
                let rook = figures.first(where: { $0.equals(Rook(color: fig.getColor(), row: fig.getRow(), file: Rook.CastleQueensideStartingFile))})!
                cache.clearField(atRow: rook.getRow(), atFile: rook.getFile())
                rook.move(row: move.getRow(), file: Rook.CastleQueensideEndFile)
                cache.set(rook)
            } else {
                let rook = figures.first(where: { $0.equals(Rook(color: fig.getColor(), row: fig.getRow(), file: Rook.CastleKingsideStartingFile))})!
                cache.clearField(atRow: rook.getRow(), atFile: rook.getFile())
                rook.move(row: move.getRow(), file: Rook.CastleKingsideEndFile)
                cache.set(rook)
            }
        }
        boardCache = PositionFactory.create(cache, afterMove: move, figures: figures, capturedPiece: capturedPiece)
    
    }
}
