import Testing
@testable import SwiftChessCore

struct PromotionRulesTests {

    @Test func testRankBeforePromotion_perColor() {
        #expect(PromotionRules.rankBeforePromotion(for: .white) == 7)
        #expect(PromotionRules.rankBeforePromotion(for: .black) == 2)
    }

    @Test func testPromotionRank_perColor() {
        #expect(PromotionRules.promotionRank(for: .white) == 8)
        #expect(PromotionRules.promotionRank(for: .black) == 1)
    }

    @Test func testIsOnRankBeforePromotion_whitePawnOnSeventh_isTrue() {
        let pawn = Figure.create("e7", type: .pawn, color: .white)!
        #expect(PromotionRules.isOnRankBeforePromotion(pawn))
    }

    @Test func testIsOnRankBeforePromotion_blackPawnOnSecond_isTrue() {
        let pawn = Figure.create("d2", type: .pawn, color: .black)!
        #expect(PromotionRules.isOnRankBeforePromotion(pawn))
    }

    @Test func testIsOnRankBeforePromotion_pawnElsewhere_isFalse() {
        let pawn = Figure.create("e6", type: .pawn, color: .white)!
        #expect(!PromotionRules.isOnRankBeforePromotion(pawn))
    }

    @Test func testIsOnRankBeforePromotion_nonPawnOnSeventh_isFalse() {
        let rook = Figure.create("e7", type: .rook, color: .white)!
        #expect(!PromotionRules.isOnRankBeforePromotion(rook))
    }

    @Test func testIsPromotion_whitePawnReachingEighth_isTrue() throws {
        let pawn = Figure.create("e7", type: .pawn, color: .white)!
        let move = try #require(Move("e8", piece: pawn, type: .promotion))
        #expect(PromotionRules.isPromotion(move))
    }

    @Test func testIsPromotion_blackPawnReachingFirst_isTrue() throws {
        let pawn = Figure.create("d2", type: .pawn, color: .black)!
        let move = try #require(Move("d1", piece: pawn, type: .promotion))
        #expect(PromotionRules.isPromotion(move))
    }

    @Test func testIsPromotion_pawnNotReachingLastRank_isFalse() throws {
        let pawn = Figure.create("e6", type: .pawn, color: .white)!
        let move = try #require(Move("e7", piece: pawn, type: .normal))
        #expect(!PromotionRules.isPromotion(move))
    }

    @Test func testIsPromotion_nonPawnReachingLastRank_isFalse() throws {
        let rook = Figure.create("e7", type: .rook, color: .white)!
        let move = try #require(Move("e8", piece: rook, type: .normal))
        #expect(!PromotionRules.isPromotion(move))
    }

    @Test func testIsPawnBeingPromoted_pawnOnDestinationSquare_isTrue() throws {
        let pawn = Figure.create("e7", type: .pawn, color: .white)!
        let move = try #require(Move("e8", piece: pawn, type: .promotion))
        let promoting = Figure.create("e8", type: .pawn, color: .white)!
        #expect(PromotionRules.isPawnBeingPromoted(promoting, by: move))
    }

    @Test func testIsPawnBeingPromoted_wrongColor_isFalse() throws {
        let pawn = Figure.create("e7", type: .pawn, color: .white)!
        let move = try #require(Move("e8", piece: pawn, type: .promotion))
        let other = Figure.create("e8", type: .pawn, color: .black)!
        #expect(!PromotionRules.isPawnBeingPromoted(other, by: move))
    }

    @Test func testIsPawnBeingPromoted_wrongSquare_isFalse() throws {
        let pawn = Figure.create("e7", type: .pawn, color: .white)!
        let move = try #require(Move("e8", piece: pawn, type: .promotion))
        let other = Figure.create("d8", type: .pawn, color: .white)!
        #expect(!PromotionRules.isPawnBeingPromoted(other, by: move))
    }

    @Test func testIsPawnBeingPromoted_nonPawnOnSquare_isFalse() throws {
        let pawn = Figure.create("e7", type: .pawn, color: .white)!
        let move = try #require(Move("e8", piece: pawn, type: .promotion))
        let queen = Figure.create("e8", type: .queen, color: .white)!
        #expect(!PromotionRules.isPawnBeingPromoted(queen, by: move))
    }
}
