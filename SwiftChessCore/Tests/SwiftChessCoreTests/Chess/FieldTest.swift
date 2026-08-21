import Testing
@testable import SwiftChessCore

struct FieldTest {

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
            let field = try #require(Field(key), "\(key) not found")
            #expect(field.file == value.file, "\(key) not found")
            #expect(field.row == value.row, "\(key) not found")
        }
    }

    @Test func testInit_singleChar_returnsNil() {
        #expect(Field("a") == nil)
        #expect(Field("1") == nil)
    }

    @Test func testInit_empty_returnsNil() {
        #expect(Field("") == nil)
    }

    @Test func testInit_dash_returnsNil() {
        #expect(Field("-") == nil)
    }
}
