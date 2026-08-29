import Testing
@testable import SwiftChess
import SwiftChessCore

struct MoveListTests {

    // MARK: - Annotation

    @Test func testSetAnnotation() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        let e4 = try #require(testee.currentMove)
        #expect(e4.annotation == nil)

        testee.setAnnotation(.brilliant, for: e4)
        #expect(e4.annotation == .brilliant)

        testee.setAnnotation(.blunder, for: e4)
        #expect(e4.annotation == .blunder)

        testee.setAnnotation(nil, for: e4)
        #expect(e4.annotation == nil)
    }

    @Test func testSetAnnotationDoesNotAffectNavigation() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        let e4 = try #require(testee.list[0].white)

        testee.setAnnotation(.mistake, for: e4)
        #expect(e4.annotation == .mistake)

        testee.start()
        testee.forward()
        #expect(testee.currentMove?.move == "e4")
        #expect(testee.currentMove?.annotation == .mistake)
    }

    // MARK: - Delete from main line

    @Test func testDeleteWhiteMoveFromMainLine() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nc3")
        testee.movePlayed("Nc6")

        let nc3 = try #require(testee.list[1].white)
        #expect(nc3.move == "Nc3")

        testee.goToMove(nc3)
        testee.deleteFrom(nc3)

        #expect(testee.list.count == 1)
        #expect(testee.list[0].white?.move == "e4")
        #expect(testee.list[0].black?.move == "e5")
        #expect(testee.currentMove == nil)
    }

    @Test func testDeleteBlackMoveKeepsWhiteInPair() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nc3")

        let e5 = try #require(testee.list[0].black)
        #expect(e5.move == "e5")

        testee.deleteFrom(e5)

        #expect(testee.list[0].white?.move == "e4")
        #expect(testee.list[0].black == nil)
        #expect(testee.list.count == 1)
        #expect(testee.currentMove == nil)
    }

    @Test func testDeleteFromKeepsCurrentMoveIfBeforeDeletion() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nc3")
        testee.movePlayed("Nc6")

        let e4 = try #require(testee.list[0].white)
        let nc3 = try #require(testee.list[1].white)
        testee.goToMove(e4)
        testee.deleteFrom(nc3)

        #expect(testee.currentMove?.move == "e4")
    }

    @Test func testDeleteFromResetsCurrentMoveIfDeleted() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nc3")

        let nc3 = try #require(testee.list[1].white)
        testee.goToMove(nc3)
        testee.deleteFrom(nc3)

        #expect(testee.currentMove == nil)
    }

    // MARK: - Delete variation

    @Test func testDeleteVariationRemovesIt() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nc3")
        testee.back()
        testee.movePlayed("Nf3")

        let branchMove = try #require(testee.list[1].white)
        #expect(branchMove.hasVariations() == true)
        #expect(branchMove.getVariations().count == 1)

        let variationName = try #require(branchMove.getVariations().first)
        testee.deleteVariation(name: variationName, from: branchMove)

        #expect(branchMove.hasVariations() == false)
        #expect(branchMove.getVariations().count == 0)
    }

    @Test func testDeleteVariationResetsCurrentMoveIfInsideIt() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nc3")
        testee.back()
        testee.movePlayed("Nf3")

        let branchMove = try #require(testee.list[1].white)
        let variationName = try #require(branchMove.getVariations().first)
        #expect(testee.currentMove?.move == "Nf3")

        testee.deleteVariation(name: variationName, from: branchMove)

        #expect(testee.currentMove == nil)
    }

    @Test func testDeleteVariationKeepsCurrentMoveIfElsewhere() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nc3")
        testee.movePlayed("Nc6")
        testee.back()
        testee.back()
        testee.movePlayed("Nf3")

        let branchMove = try #require(testee.list[1].white)
        let variationName = try #require(branchMove.getVariations().first)

        let nc6 = try #require(testee.list[1].black)
        testee.goToMove(nc6)
        testee.deleteVariation(name: variationName, from: branchMove)

        #expect(testee.currentMove?.move == "Nc6")
    }

    // MARK: - Delete from variation

    @Test func testDeleteFromVariationMove() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nc3")
        testee.back()
        testee.movePlayed("Nf3")
        testee.movePlayed("Nf6")

        let branchMove = try #require(testee.list[1].white)
        let variationName = try #require(branchMove.getVariations().first)
        let variation = try #require(branchMove.getVariation(variationName))

        let nf6 = try #require(variation.all[0].black)
        #expect(nf6.move == "Nf6")

        testee.deleteFrom(nf6)

        #expect(variation.all[0].black == nil)
        #expect(variation.all.count == 1)
        #expect(testee.currentMove == nil)
    }

    @Test func testDeleteFromVariationResetsCurrentMoveIfDeleted() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nc3")
        testee.back()
        testee.movePlayed("Nf3")
        testee.movePlayed("Nf6")

        let branchMove = try #require(testee.list[1].white)
        let variationName = try #require(branchMove.getVariations().first)
        let variation = try #require(branchMove.getVariation(variationName))
        let nf3 = try #require(variation.all[0].white)

        testee.goToMove(nf3)
        testee.deleteFrom(nf3)

        #expect(testee.currentMove == nil)
    }
}
