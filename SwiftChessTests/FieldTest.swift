//
//  MoveFActoryTest.swift
//  SwiftChessTests
//
//  Created by Jan Fässler on 07.03.2024.
//

import XCTest
import SwiftChess

final class FieldTest: XCTestCase {
    
    func testExample() throws {
        
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
            let field = Field(key)
            
            XCTAssertNotNil(field)
            XCTAssertEqual(field?.file, value.file, "\(key) not found")
            XCTAssertEqual(field?.row, value.row, "\(key) not found")
        }
    }


}
