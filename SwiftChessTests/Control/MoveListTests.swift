import Testing
@testable import SwiftChess
import SwiftChessCore

struct MoveListTests {

    let testee = MoveListModel()

    @Test func testShouldShowVariationList() throws {
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nc3")
        testee.movePlayed("Nc6")
        testee.back()
        let root = try #require(testee.currentMove)
        let rootPair = testee.list[1]
        #expect(root.move == "Nc3")
        #expect(rootPair.white?.move == root.move)
        #expect(root.hasVariations() == false)
        #expect(!showVariations(rootPair, in: testee))
        #expect(!showVariations(rootPair, color: .white, in: testee))
        #expect(!showVariations(rootPair, color: .black, in: testee))

        testee.back()
        testee.movePlayed("Nf3")
        let variationFirst = try #require(testee.currentMove)
        let variation = try #require(root.getVariation(variationFirst))
        let variationPair = variation.all[0]
        #expect(variationFirst.move == "Nf3")
        #expect(variationPair.white?.move == "Nf3")
        #expect(root.hasVariations() == true)
        #expect(showVariations(rootPair, in: testee))
        #expect(showVariations(rootPair, color: .white, in: testee))
        #expect(!showVariations(rootPair, color: .black, in: testee))
        #expect(!showVariations(variationPair, in: testee))
        #expect(!showVariations(variationPair, color: .white, in: testee))
        #expect(!showVariations(variationPair, color: .black, in: testee))

        testee.movePlayed("Nf6")
        let variationSecound = try #require(testee.currentMove)
        #expect(variationSecound.move == "Nf6")
        #expect(variationPair.white?.move == "Nf3")
        #expect(variationPair.black?.move == "Nf6")
        #expect(root.hasVariations() == true)
        #expect(showVariations(rootPair, in: testee))
        #expect(showVariations(rootPair, color: .white, in: testee))
        #expect(!showVariations(rootPair, color: .black, in: testee))
        #expect(!showVariations(variationPair, in: testee))
        #expect(!showVariations(variationPair, color: .white, in: testee))
        #expect(!showVariations(variationPair, color: .black, in: testee))

        testee.back()
        testee.movePlayed("Nc6")
        let supVariationFirst = try #require(testee.currentMove)
        let supVariation = try #require(variationSecound.getVariation(try #require(supVariationFirst)))
        let supVariationPairFirst = supVariation.all[0]
        #expect(supVariationFirst.move == "Nc6")
        #expect(supVariationPairFirst.white == nil)
        #expect(supVariationPairFirst.black?.move == "Nc6")
        #expect(root.hasVariations() == true)
        #expect(variationSecound.hasVariations() == true)
        #expect(showVariations(rootPair, in: testee))
        #expect(showVariations(rootPair, color: .white, in: testee))
        #expect(!showVariations(rootPair, color: .black, in: testee))
        #expect(showVariations(variationPair, in: testee))
        #expect(!showVariations(variationPair, color: .white, in: testee))
        #expect(showVariations(variationPair, color: .black, in: testee))
        #expect(!showVariations(supVariationPairFirst, in: testee))
        #expect(!showVariations(supVariationPairFirst, color: .white, in: testee))
        #expect(!showVariations(supVariationPairFirst, color: .black, in: testee))

        testee.movePlayed("Nc3")
        let supVariationSecound = try #require(testee.currentMove)
        let supVariationPairSecond = supVariation.all[1]
        #expect(supVariationSecound.move == "Nc3")
        #expect(supVariationPairSecond.white?.move == "Nc3")
        #expect(supVariationPairSecond.black == nil)
        #expect(root.hasVariations() == true)
        #expect(variationSecound.hasVariations() == true)
        #expect(showVariations(rootPair, in: testee))
        #expect(showVariations(rootPair, color: .white, in: testee))
        #expect(!showVariations(rootPair, color: .black, in: testee))
        #expect(showVariations(variationPair, in: testee))
        #expect(!showVariations(variationPair, color: .white, in: testee))
        #expect(showVariations(variationPair, color: .black, in: testee))
        #expect(!showVariations(supVariationPairFirst, in: testee))
        #expect(!showVariations(supVariationPairFirst, color: .white, in: testee))
        #expect(!showVariations(supVariationPairFirst, color: .black, in: testee))
    }

    private func showVariations(_ pair: MovePairModel, in model: MoveListModel) -> Bool {
        showVariations(pair, color: .white, in: model) || showVariations(pair, color: .black, in: model)
    }

    private func showVariations(_ pair: MovePairModel, color: PieceColor, in model: MoveListModel) -> Bool {
        guard let current = model.currentMove else { return false }
        if color == .white {
            guard let white = pair.white else { return false }
            return current == white ? white.hasVariations() : model.isMove(current, childOf: white)
        } else {
            guard let black = pair.black else { return false }
            return current == black ? black.hasVariations() : model.isMove(current, childOf: black)
        }
    }
}
