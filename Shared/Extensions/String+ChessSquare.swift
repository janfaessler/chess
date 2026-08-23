import Foundation

extension String {
    var chessFileIndex: Int {
        guard let ascii = first?.asciiValue else { return 1 }
        return Int(ascii - 97) + 1  // 97 = 'a'
    }

    var chessRowIndex: Int {
        guard count >= 2, let r = Int(dropFirst()) else { return 1 }
        return r
    }
}
