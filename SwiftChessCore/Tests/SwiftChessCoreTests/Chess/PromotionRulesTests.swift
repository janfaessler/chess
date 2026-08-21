import XCTest
@testable import SwiftChessCore

final class PromotionRulesTests: XCTestCase {

    func testRankBeforePromotion_perColor() {
        XCTAssertEqual(PromotionRules.rankBeforePromotion(for: .white), 7)
        XCTAssertEqual(PromotionRules.rankBeforePromotion(for: .black), 2)
    }

    func testPromotionRank_perColor() {
        XCTAssertEqual(PromotionRules.promotionRank(for: .white), 8)
        XCTAssertEqual(PromotionRules.promotionRank(for: .black), 1)
    }

    func testIsOnRankBeforePromotion_whitePawnOnSeventh_isTrue() {
        let pawn = Figure.create("e7", type: .pawn, color: .white)!
        XCTAssertTrue(PromotionRules.isOnRankBeforePromotion(pawn))
    }

    func testIsOnRankBeforePromotion_blackPawnOnSecond_isTrue() {
        let pawn = Figure.create("d2", type: .pawn, color: .black)!
        XCTAssertTrue(PromotionRules.isOnRankBeforePromotion(pawn))
    }

    func testIsOnRankBeforePromotion_pawnElsewhere_isFalse() {
        let pawn = Figure.create("e6", type: .pawn, color: .white)!
        XCTAssertFalse(PromotionRules.isOnRankBeforePromotion(pawn))
    }

    func testIsOnRankBeforePromotion_nonPawnOnSeventh_isFalse() {
        let rook = Figure.create("e7", type: .rook, color: .white)!
        XCTAssertFalse(PromotionRules.isOnRankBeforePromotion(rook))
    }

    func testIsPromotion_whitePawnReachingEighth_isTrue() throws {
        let pawn = Figure.create("e7", type: .pawn, color: .white)!
        let move = try XCTUnwrap(Move("e8", piece: pawn, type: .Promotion))
        XCTAssertTrue(PromotionRules.isPromotion(move))
    }

    func testIsPromotion_blackPawnReachingFirst_isTrue() throws {
        let pawn = Figure.create("d2", type: .pawn, color: .black)!
        let move = try XCTUnwrap(Move("d1", piece: pawn, type: .Promotion))
        XCTAssertTrue(PromotionRules.isPromotion(move))
    }

    func testIsPromotion_pawnNotReachingLastRank_isFalse() throws {
        let pawn = Figure.create("e6", type: .pawn, color: .white)!
        let move = try XCTUnwrap(Move("e7", piece: pawn, type: .Normal))
        XCTAssertFalse(PromotionRules.isPromotion(move))
    }

    func testIsPromotion_nonPawnReachingLastRank_isFalse() throws {
        let rook = Figure.create("e7", type: .rook, color: .white)!
        let move = try XCTUnwrap(Move("e8", piece: rook, type: .Normal))
        XCTAssertFalse(PromotionRules.isPromotion(move))
    }

    func testIsPawnBeingPromoted_pawnOnDestinationSquare_isTrue() throws {
        let pawn = Figure.create("e7", type: .pawn, color: .white)!
        let move = try XCTUnwrap(Move("e8", piece: pawn, type: .Promotion))
        let promoting = Figure.create("e8", type: .pawn, color: .white)!
        XCTAssertTrue(PromotionRules.isPawnBeingPromoted(promoting, by: move))
    }

    func testIsPawnBeingPromoted_wrongColor_isFalse() throws {
        let pawn = Figure.create("e7", type: .pawn, color: .white)!
        let move = try XCTUnwrap(Move("e8", piece: pawn, type: .Promotion))
        let other = Figure.create("e8", type: .pawn, color: .black)!
        XCTAssertFalse(PromotionRules.isPawnBeingPromoted(other, by: move))
    }

    func testIsPawnBeingPromoted_wrongSquare_isFalse() throws {
        let pawn = Figure.create("e7", type: .pawn, color: .white)!
        let move = try XCTUnwrap(Move("e8", piece: pawn, type: .Promotion))
        let other = Figure.create("d8", type: .pawn, color: .white)!
        XCTAssertFalse(PromotionRules.isPawnBeingPromoted(other, by: move))
    }

    func testIsPawnBeingPromoted_nonPawnOnSquare_isFalse() throws {
        let pawn = Figure.create("e7", type: .pawn, color: .white)!
        let move = try XCTUnwrap(Move("e8", piece: pawn, type: .Promotion))
        let queen = Figure.create("e8", type: .queen, color: .white)!
        XCTAssertFalse(PromotionRules.isPawnBeingPromoted(queen, by: move))
    }
}
