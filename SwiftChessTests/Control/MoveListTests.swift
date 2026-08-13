import XCTest
@testable import SwiftChess

final class MoveListTests: XCTestCase {

    private var testee:MoveListModel? = nil

    override func setUpWithError() throws {
        testee = MoveListModel()
    }

    func testShouldShowVariationList() throws {
        let testee = try XCTUnwrap(testee)
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nc3")
        testee.movePlayed("Nc6")
        testee.back()
        let root = try XCTUnwrap(testee.currentMove)
        let rootPair = testee.list[1]
        XCTAssertEqual(root.move, "Nc3")
        XCTAssertEqual(rootPair.white?.move, root.move)
        XCTAssertEqual(root.hasVariations(), false)
        XCTAssertFalse(showVariations(rootPair, in: testee))
        XCTAssertFalse(showVariations(rootPair, color: .white, in: testee))
        XCTAssertFalse(showVariations(rootPair, color: .black, in: testee))

        testee.back()
        testee.movePlayed("Nf3")
        let variationFirst = try XCTUnwrap(testee.currentMove)
        let variation = try XCTUnwrap(root.getVariation(variationFirst))
        let variationPair = variation.all[0]
        XCTAssertEqual(variationFirst.move, "Nf3")
        XCTAssertEqual(variationPair.white?.move, "Nf3")
        XCTAssertEqual(root.hasVariations(), true)
        XCTAssertTrue(showVariations(rootPair, in: testee))
        XCTAssertTrue(showVariations(rootPair, color: .white, in: testee))
        XCTAssertFalse(showVariations(rootPair, color: .black, in: testee))
        XCTAssertFalse(showVariations(variationPair, in: testee))
        XCTAssertFalse(showVariations(variationPair, color: .white, in: testee))
        XCTAssertFalse(showVariations(variationPair, color: .black, in: testee))

        testee.movePlayed("Nf6")
        let variationSecound = try XCTUnwrap(testee.currentMove)
        XCTAssertEqual(variationSecound.move, "Nf6")
        XCTAssertEqual(variationPair.white?.move, "Nf3")
        XCTAssertEqual(variationPair.black?.move, "Nf6")
        XCTAssertEqual(root.hasVariations(), true)
        XCTAssertTrue(showVariations(rootPair, in: testee))
        XCTAssertTrue(showVariations(rootPair, color: .white, in: testee))
        XCTAssertFalse(showVariations(rootPair, color: .black, in: testee))
        XCTAssertFalse(showVariations(variationPair, in: testee))
        XCTAssertFalse(showVariations(variationPair, color: .white, in: testee))
        XCTAssertFalse(showVariations(variationPair, color: .black, in: testee))

        testee.back()
        testee.movePlayed("Nc6")
        let supVariationFirst = try XCTUnwrap(testee.currentMove)
        let supVariation = try XCTUnwrap(variationSecound.getVariation(try XCTUnwrap(supVariationFirst)))
        let supVariationPairFirst = supVariation.all[0]
        XCTAssertEqual(supVariationFirst.move, "Nc6")
        XCTAssertNil(supVariationPairFirst.white)
        XCTAssertEqual(supVariationPairFirst.black?.move, "Nc6")
        XCTAssertEqual(root.hasVariations(), true)
        XCTAssertEqual(variationSecound.hasVariations(), true)
        XCTAssertTrue(showVariations(rootPair, in: testee))
        XCTAssertTrue(showVariations(rootPair, color: .white, in: testee))
        XCTAssertFalse(showVariations(rootPair, color: .black, in: testee))
        XCTAssertTrue(showVariations(variationPair, in: testee))
        XCTAssertFalse(showVariations(variationPair, color: .white, in: testee))
        XCTAssertTrue(showVariations(variationPair, color: .black, in: testee))
        XCTAssertFalse(showVariations(supVariationPairFirst, in: testee))
        XCTAssertFalse(showVariations(supVariationPairFirst, color: .white, in: testee))
        XCTAssertFalse(showVariations(supVariationPairFirst, color: .black, in: testee))

        testee.movePlayed("Nc3")
        let supVariationSecound = try XCTUnwrap(testee.currentMove)
        let supVariationPairSecond = supVariation.all[1]
        XCTAssertEqual(supVariationSecound.move, "Nc3")
        XCTAssertEqual(supVariationPairSecond.white?.move, "Nc3")
        XCTAssertNil(supVariationPairSecond.black)
        XCTAssertEqual(root.hasVariations(), true)
        XCTAssertEqual(variationSecound.hasVariations(), true)
        XCTAssertTrue(showVariations(rootPair, in: testee))
        XCTAssertTrue(showVariations(rootPair, color: .white, in: testee))
        XCTAssertFalse(showVariations(rootPair, color: .black, in: testee))
        XCTAssertTrue(showVariations(variationPair, in: testee))
        XCTAssertFalse(showVariations(variationPair, color: .white, in: testee))
        XCTAssertTrue(showVariations(variationPair, color: .black, in: testee))
        XCTAssertFalse(showVariations(supVariationPairFirst, in: testee))
        XCTAssertFalse(showVariations(supVariationPairFirst, color: .white, in: testee))
        XCTAssertFalse(showVariations(supVariationPairFirst, color: .black, in: testee))
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
