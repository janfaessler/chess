import Testing
@testable import SwiftChess

struct MoveStructureTests {

    let testee = MoveListModel()

    @Test func testTopLevelMoveNavigation() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        for move in testMoves {
            testee.movePlayed(move)
        }

        testee.start()
        #expect(testee.isCurrentMove(nil))
        for move in testMoves {
            testee.forward()
            #expect(testee.currentMove?.move == move)
        }

        testee.start()
        testee.end()

        for move in testMoves.reversed() {
            #expect(testee.currentMove?.move == move)
            testee.back()
        }
        #expect(testee.currentMove == nil)
    }

    @Test func testMoveVariationOnBlack() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        for move in testMoves {
            testee.movePlayed(move)
        }

        testee.back()
        #expect(testee.currentMove?.move == "Nc3")
        testee.back()
        #expect(testee.currentMove?.move == "e5")

        testee.movePlayed("Bc4")
        #expect(testee.currentMove?.move == "Bc4")

        testee.movePlayed("Bc5")
        #expect(testee.currentMove?.move == "Bc5")

        testee.back()
        #expect(testee.currentMove?.move == "Bc4")
        testee.forward()
        #expect(testee.currentMove?.move == "Bc5")

        testee.movePlayed("d3")
        #expect(testee.currentMove?.move == "d3")

        testee.movePlayed("d6")
        #expect(testee.currentMove?.move == "d6")

        let variation = testee.list[1].white?.getVariation("Bc4")?.all
        #expect(variation?[0].moveNumber == 2)
        #expect(variation?[0].white!.move == "Bc4")
        #expect(variation?[0].white!.getVariations().count == 0)
        #expect(variation?[0].black!.move == "Bc5")
        #expect(variation?[0].black!.getVariations().count == 0)
        #expect(variation?[1].moveNumber == 3)
        #expect(variation?[1].white!.move == "d3")
        #expect(variation?[1].white!.getVariations().count == 0)
        #expect(variation?[1].black!.move == "d6")
        #expect(variation?[1].black!.getVariations().count == 0)
    }

    @Test func testMoveVariationOnWhite() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        for move in testMoves {
            testee.movePlayed(move)
        }

        testee.back()
        #expect(testee.currentMove?.move == "Nc3")

        testee.movePlayed("Bc5")
        #expect(testee.currentMove?.move == "Bc5")

        testee.movePlayed("Bc4")
        #expect(testee.currentMove?.move == "Bc4")

        testee.back()
        #expect(testee.currentMove?.move == "Bc5")
        testee.forward()
        #expect(testee.currentMove?.move == "Bc4")

        testee.movePlayed("d6")
        #expect(testee.currentMove?.move == "d6")

        testee.movePlayed("d3")
        #expect(testee.currentMove?.move == "d3")

        testee.back()
        testee.movePlayed("d3")
        #expect(testee.currentMove?.move == "d3")

        let variation = testee.list[1].black?.getVariation("Bc5")?.all
        #expect(variation?[0].moveNumber == 2)
        #expect(variation?[0].white == nil)
        #expect(variation?[0].black!.move == "Bc5")
        #expect(variation?[0].black!.getVariations().count == 0)
        #expect(variation?[1].moveNumber == 3)
        #expect(variation?[1].white!.move == "Bc4")
        #expect(variation?[1].white!.getVariations().count == 0)
        #expect(variation?[1].black!.move == "d6")
        #expect(variation?[1].black!.getVariations().count == 0)
        #expect(variation?[2].moveNumber == 4)
        #expect(variation?[2].white!.move == "d3")
        #expect(variation?[2].white!.getVariations().count == 0)
        #expect(variation?[2].black == nil)
    }

    @Test func testGoToMoveWithTwoVariations() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        for move in testMoves {
            testee.movePlayed(move)
        }

        let variationStart = try #require(testee.list[0].black)
        testee.goToMove(variationStart)
        #expect(testee.currentMove?.move == variationStart.move)

        testee.movePlayed("Bc4")
        #expect(testee.currentMove?.move == "Bc4")

        testee.movePlayed("Bc5")
        #expect(testee.currentMove?.move == "Bc5")

        testee.goToMove(variationStart)
        #expect(testee.currentMove?.move == variationStart.move)

        testee.movePlayed("d3")
        #expect(testee.currentMove?.move == "d3")

        testee.movePlayed("d6")
        #expect(testee.currentMove?.move == "d6")

        testee.goToMove(try #require(testee.list[1].white?.getVariation("Bc4")?.all[0].white))
        #expect(testee.currentMove?.move == "Bc4")

        #expect(testee.list[1].white?.getVariations().count == 2)
        let variationD3 = testee.list[1].white?.getVariation("d3")?.all
        #expect(variationD3?[0].white!.move == "d3")
        #expect(variationD3?[0].white!.getVariations().count == 0)
        #expect(variationD3?[0].black!.move == "d6")
        #expect(variationD3?[0].black!.getVariations().count == 0)

        let variationBc4 = testee.list[1].white?.getVariation("Bc4")?.all
        #expect(variationBc4?[0].white!.move == "Bc4")
        #expect(variationBc4?[0].white!.getVariations().count == 0)
        #expect(variationBc4?[0].black!.move == "Bc5")
        #expect(variationBc4?[0].black!.getVariations().count == 0)
    }

    @Test func testSubVariationBlackOnWhite() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        for move in testMoves {
            testee.movePlayed(move)
        }

        testee.back()
        #expect(testee.currentMove?.move == "Nc3")

        testee.movePlayed("Bc5")
        #expect(testee.currentMove?.move == "Bc5")

        testee.movePlayed("Bc4")
        #expect(testee.currentMove?.move == "Bc4")

        testee.movePlayed("d6")
        #expect(testee.currentMove?.move == "d6")

        testee.movePlayed("d3")
        #expect(testee.currentMove?.move == "d3")

        testee.back()
        #expect(testee.currentMove?.move == "d6")

        testee.back()
        #expect(testee.currentMove?.move == "Bc4")

        testee.back()
        #expect(testee.currentMove?.move == "Bc5")

        testee.movePlayed("d3")
        #expect(testee.currentMove?.move == "d3")

        testee.movePlayed("d6")
        #expect(testee.currentMove?.move == "d6")

        testee.movePlayed("Be2")
        #expect(testee.currentMove?.move == "Be2")

        #expect(testee.list[1].black?.getVariations().count == 1)
        let variation = testee.list[1].black?.getVariation("Bc5")?.all
        #expect(variation?[0].moveNumber == 2)
        #expect(variation?[0].black!.move == "Bc5")
        #expect(variation?[0].black!.getVariations().count == 0)
        #expect(variation?[1].moveNumber == 3)
        #expect(variation?[1].white!.move == "Bc4")
        #expect(variation?[1].white!.getVariations().count == 1)
        #expect(variation?[1].black!.move == "d6")
        #expect(variation?[1].black!.getVariations().count == 0)
        #expect(variation?[2].moveNumber == 4)
        #expect(variation?[2].white!.move == "d3")
        #expect(variation?[2].white!.getVariations().count == 0)

        let subVariation = variation?[1].white?.getVariation("d3")?.all
        #expect(subVariation?[0].moveNumber == 3)
        #expect(subVariation?[0].white!.move == "d3")
        #expect(subVariation?[0].white!.getVariations().count == 0)
        #expect(subVariation?[0].black!.move == "d6")
        #expect(subVariation?[0].black!.getVariations().count == 0)
        #expect(subVariation?[1].moveNumber == 4)
        #expect(subVariation?[1].white!.move == "Be2")
        #expect(subVariation?[1].white!.getVariations().count == 0)
        #expect(subVariation?[1].black == nil)
    }

    @Test func testSubVariationWhiteOnBlack() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        for move in testMoves {
            testee.movePlayed(move)
        }

        testee.back()
        #expect(testee.currentMove?.move == "Nc3")

        testee.back()
        #expect(testee.currentMove?.move == "e5")

        testee.movePlayed("Bc4")
        #expect(testee.currentMove?.move == "Bc4")

        testee.movePlayed("Bc5")
        #expect(testee.currentMove?.move == "Bc5")

        testee.movePlayed("d3")
        #expect(testee.currentMove?.move == "d3")

        testee.movePlayed("d6")
        #expect(testee.currentMove?.move == "d6")

        testee.back()
        #expect(testee.currentMove?.move == "d3")

        testee.back()
        #expect(testee.currentMove?.move == "Bc5")

        testee.back()
        #expect(testee.currentMove?.move == "Bc4")

        testee.movePlayed("d6")
        #expect(testee.currentMove?.move == "d6")

        testee.movePlayed("d3")
        #expect(testee.currentMove?.move == "d3")

        #expect(testee.list[1].white!.getVariations().count == 1)
        let variation = testee.list[1].white?.getVariation("Bc4")?.all
        #expect(variation?[0].moveNumber == 2)
        #expect(variation?[0].white!.move == "Bc4")
        #expect(variation?[0].white!.getVariations().count == 0)
        #expect(variation?[0].black!.move == "Bc5")
        #expect(variation?[0].black!.getVariations().count == 1)
        #expect(variation?[1].moveNumber == 3)
        #expect(variation?[1].white!.move == "d3")
        #expect(variation?[1].white!.getVariations().count == 0)
        #expect(variation?[1].black!.move == "d6")
        #expect(variation?[1].black!.getVariations().count == 0)
        #expect(variation?[0].black?.getVariations().count == 1)

        let subVariation = variation?[0].black?.getVariation("d6")?.all
        #expect(subVariation?[0].moveNumber == 2)
        #expect(subVariation?[0].white == nil)
        #expect(subVariation?[0].black!.move == "d6")
        #expect(subVariation?[0].black!.getVariations().count == 0)
        #expect(subVariation?[1].moveNumber == 3)
        #expect(subVariation?[1].white!.move == "d3")
        #expect(subVariation?[1].white!.getVariations().count == 0)
        #expect(subVariation?[1].black == nil)
    }
}
