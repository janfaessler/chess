import Foundation

public struct Square: Equatable, Hashable, Sendable {

    private static let aAscii: UInt8 = Character("a").asciiValue!

    public let row: Int
    public let file: Int

    public init?(row: Int, file: Int) {
        guard 1...BoardConstants.size ~= row && 1...BoardConstants.size ~= file else { return nil }
        self.row = row
        self.file = file
    }

    public static func isValid(row: Int, file: Int) -> Bool {
        1...BoardConstants.size ~= row && 1...BoardConstants.size ~= file
    }

    public init?(_ square: any StringProtocol) {
        guard let fileChar = square.first,
              let fVal = fileChar.asciiValue,
              fVal >= Square.aAscii,
              let secondChar = square.dropFirst().first,
              let row = secondChar.wholeNumberValue,
              1...BoardConstants.size ~= row else { return nil }
        let file = Int(fVal - Square.aAscii) + 1
        guard 1...BoardConstants.size ~= file else { return nil }
        self.file = file
        self.row = row
    }

    public var info: String {
        let fileChar = Character(UnicodeScalar(Int(Square.aAscii) + file - 1)!)
        return "\(fileChar)\(row)"
    }

    public var fileName: String {
        String(Character(UnicodeScalar(Int(Square.aAscii) + file - 1)!))
    }

    public static func == (l: Square, r: Square) -> Bool {
        return l.row == r.row && l.file == r.file
    }
}
