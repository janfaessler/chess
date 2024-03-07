//
//  Field.swift
//  SwiftChess
//
//  Created by Jan Fässler on 07.03.2024.
//

import Foundation

public class Field {
    private let fileNames = zip("abcdefgh", 1...8).reduce(into: [:]) { $0[$1.0] = $1.1 }
    private let fileNamesOut = zip(1...8, "abcdefgh").reduce(into: [:]) { $0[$1.0] = $1.1 }

    public let row:Int
    public let file:Int
    
    init(row:Int, file:Int) {
        self.row = row
        self.file = file
    }
    
    public init?(_ field:String) {
        let chars = [Character](field)
        guard let file = fileNames[chars[0]] else { return nil }
        guard let row = Int(String(chars[1])) else { return nil }
        self.file = file
        self.row = row
    }
    
    public func info() -> String {
        guard let filename = fileNamesOut[file] else { return "??" }
        return "\(filename)\(row)"
    }
}
