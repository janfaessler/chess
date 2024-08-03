import XCTest
import SwiftChess

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
        XCTAssertFalse(testee.shouldShowVariationList(rootPair))
        XCTAssertFalse(testee.shouldShowVariationList(rootPair, color: .white))
        XCTAssertFalse(testee.shouldShowVariationList(rootPair, color: .black))
        
        testee.back()
        testee.movePlayed("Nf3")
        let variationFirst = try XCTUnwrap(testee.currentMove)
        let variation = try XCTUnwrap(root.getVariation(variationFirst))
        let variationPair = variation.all[0]
        XCTAssertEqual(variationFirst.move, "Nf3")
        XCTAssertEqual(variationPair.white?.move, "Nf3")
        XCTAssertEqual(root.hasVariations(), true)
        XCTAssertTrue(testee.shouldShowVariationList(rootPair))
        XCTAssertTrue(testee.shouldShowVariationList(rootPair, color: .white))
        XCTAssertFalse(testee.shouldShowVariationList(rootPair, color: .black))
        XCTAssertFalse(testee.shouldShowVariationList(variationPair))
        XCTAssertFalse(testee.shouldShowVariationList(variationPair, color: .white))
        XCTAssertFalse(testee.shouldShowVariationList(variationPair, color: .black))
        
        testee.movePlayed("Nf6")
        let variationSecound = try XCTUnwrap(testee.currentMove)
        XCTAssertEqual(variationSecound.move, "Nf6")
        XCTAssertEqual(variationPair.white?.move, "Nf3")
        XCTAssertEqual(variationPair.black?.move, "Nf6")
        XCTAssertEqual(root.hasVariations(), true)
        XCTAssertTrue(testee.shouldShowVariationList(rootPair))
        XCTAssertTrue(testee.shouldShowVariationList(rootPair, color: .white))
        XCTAssertFalse(testee.shouldShowVariationList(rootPair, color: .black))
        XCTAssertFalse(testee.shouldShowVariationList(variationPair))
        XCTAssertFalse(testee.shouldShowVariationList(variationPair, color: .white))
        XCTAssertFalse(testee.shouldShowVariationList(variationPair, color: .black))
        
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
        XCTAssertTrue(testee.shouldShowVariationList(rootPair))
        XCTAssertTrue(testee.shouldShowVariationList(rootPair, color: .white))
        XCTAssertFalse(testee.shouldShowVariationList(rootPair, color: .black))
        XCTAssertTrue(testee.shouldShowVariationList(variationPair))
        XCTAssertFalse(testee.shouldShowVariationList(variationPair, color: .white))
        XCTAssertTrue(testee.shouldShowVariationList(variationPair, color: .black))
        XCTAssertFalse(testee.shouldShowVariationList(supVariationPairFirst))
        XCTAssertFalse(testee.shouldShowVariationList(supVariationPairFirst, color: .white))
        XCTAssertFalse(testee.shouldShowVariationList(supVariationPairFirst, color: .black))
        
        testee.movePlayed("Nc3")
        let supVariationSecound = try XCTUnwrap(testee.currentMove)
        let supVariationPairSecond = supVariation.all[1]
        XCTAssertEqual(supVariationSecound.move, "Nc3")
        XCTAssertEqual(supVariationPairSecond.white?.move, "Nc3")
        XCTAssertNil(supVariationPairSecond.black)
        XCTAssertEqual(root.hasVariations(), true)
        XCTAssertEqual(variationSecound.hasVariations(), true)
        XCTAssertTrue(testee.shouldShowVariationList(rootPair))
        XCTAssertTrue(testee.shouldShowVariationList(rootPair, color: .white))
        XCTAssertFalse(testee.shouldShowVariationList(rootPair, color: .black))
        XCTAssertTrue(testee.shouldShowVariationList(variationPair))
        XCTAssertFalse(testee.shouldShowVariationList(variationPair, color: .white))
        XCTAssertTrue(testee.shouldShowVariationList(variationPair, color: .black))
        XCTAssertFalse(testee.shouldShowVariationList(supVariationPairFirst))
        XCTAssertFalse(testee.shouldShowVariationList(supVariationPairFirst, color: .white))
        XCTAssertFalse(testee.shouldShowVariationList(supVariationPairFirst, color: .black))
    }
}
