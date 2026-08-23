import Testing
@testable import SwiftChessCore

struct SquareTests {

    @Test func testExample() throws {
        let data = [
            "a3": (row: 3, file: 1),
            "a4": (row: 4, file: 1),
            "b6": (row: 6, file: 2),
            "c8": (row: 8, file: 3),
            "d7": (row: 7, file: 4),
            "e1": (row: 1, file: 5),
            "f2": (row: 2, file: 6),
            "g5": (row: 5, file: 7),
            "h3": (row: 3, file: 8),
        ]

        for (key, value) in data {
            let square = try #require(Square(key), "\(key) not found")
            #expect(square.file == value.file, "\(key) not found")
            #expect(square.row == value.row, "\(key) not found")
        }
    }

    @Test func testInit_singleChar_returnsNil() {
        #expect(Square("a") == nil)
        #expect(Square("1") == nil)
    }

    @Test func testInit_empty_returnsNil() {
        #expect(Square("") == nil)
    }

    @Test func testInit_dash_returnsNil() {
        #expect(Square("-") == nil)
    }

    @Test func testInit_rowFile_validCorners_returnsSquare() {
        #expect(Square(row: 1, file: 1) != nil)
        #expect(Square(row: 8, file: 8) != nil)
        #expect(Square(row: 1, file: 8) != nil)
        #expect(Square(row: 8, file: 1) != nil)
    }

    @Test func testInit_rowFile_outOfBounds_returnsNil() {
        #expect(Square(row: 0, file: 1) == nil)
        #expect(Square(row: 9, file: 1) == nil)
        #expect(Square(row: 1, file: 0) == nil)
        #expect(Square(row: 1, file: 9) == nil)
    }

    @Test func testIsValid_inBounds_returnsTrue() {
        #expect(Square.isValid(row: 4, file: 4))
    }

    @Test func testIsValid_outOfBounds_returnsFalse() {
        #expect(!Square.isValid(row: 0, file: 4))
        #expect(!Square.isValid(row: 4, file: 9))
    }
}
