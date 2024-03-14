import Foundation

public struct Field {
    
    private static let PossibleFileNames: String = "abcdefgh"
    
    private let fileNames = zip(PossibleFileNames, 1...8).reduce(into: [:]) { $0[$1.0] = $1.1 }
    private let fileNamesOut = zip(1...8, PossibleFileNames).reduce(into: [:]) { $0[$1.0] = $1.1 }

    public let row:Int
    public let file:Int
    
    init(row:Int, file:Int) {
        self.row = row
        self.file = file
    }
    
    public init?(_ field:any StringProtocol) {
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
    
    public func getFileName() -> String {
        guard let filename = fileNamesOut[file] else { return "??" }
        return "\(filename)"
    }

}
