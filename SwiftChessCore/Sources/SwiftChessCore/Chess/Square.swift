import Foundation

public struct Square: Equatable, Hashable, Sendable {

    private static let aAscii: UInt8 = Character("a").asciiValue!

    public let row: Int
    public let file: Int
    public let info: String
    public let fileName: String

    public init?(row: Int, file: Int) {
        guard 1...BoardConstants.size ~= row && 1...BoardConstants.size ~= file else { return nil }
        self.row = row
        self.file = file
        self.fileName = Square.fileName(for: file)
        self.info = "\(self.fileName)\(row)"
    }
    
    public init?(_ square: any StringProtocol) {
        let (row, file) = Square.parseSquare(square)
        guard let row, let file else { return nil }
        guard 1...BoardConstants.size ~= file else { return nil }
        self.file = file
        self.row = row
        self.fileName = Square.fileName(for: file)
        self.info = "\(self.fileName)\(row)"
    }

    public static func isValid(row: Int, file: Int) -> Bool {
        1...BoardConstants.size ~= row && 1...BoardConstants.size ~= file
    }

    public static func == (l: Square, r: Square) -> Bool {
        return l.row == r.row && l.file == r.file
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(file)
    }
    
    private static func parseSquare(_ square: any StringProtocol) -> (row:Int?, file:Int?) {
        guard let fileChar = square.first,
              let fVal = fileChar.asciiValue,
              fVal >= Square.aAscii,
              let secondChar = square.dropFirst().first,
              let row = secondChar.wholeNumberValue,
              1...BoardConstants.size ~= row else { return (nil, nil) }
        let file = Int(fVal - Square.aAscii) + 1
        return (row: row, file: file)
    }

    private static func fileName(for file: Int) -> String {
        String(Character(UnicodeScalar(Int(Square.aAscii) + file - 1)!))
    }
}
