import Foundation

public struct Square: Equatable, Hashable, Sendable {

    private static let PossibleFileNames: String = "abcdefgh"
    private static let fileNames: [Character: Int] = zip(PossibleFileNames, 1...8).reduce(into: [:]) { $0[$1.0] = $1.1 }
    private static let fileNamesOut: [Int: Character] = zip(1...8, PossibleFileNames).reduce(into: [:]) { $0[$1.0] = $1.1 }

    public let row: Int
    public let file: Int

    public init(row: Int, file: Int) {
        self.row = row
        self.file = file
    }

    public init?(_ square: any StringProtocol) {
        let chars = [Character](square)
        guard chars.count >= 2,
              let file = Square.fileNames[chars[0]],
              let row = Int(String(chars[1])) else { return nil }
        self.file = file
        self.row = row
    }

    public var info: String {
        guard let filename = Square.fileNamesOut[file] else { return "??" }
        return "\(filename)\(row)"
    }

    public var fileName: String {
        guard let filename = Square.fileNamesOut[file] else { return "??" }
        return "\(filename)"
    }

    public static func == (l: Square, r: Square) -> Bool {
        return l.row == r.row && l.file == r.file
    }
}
