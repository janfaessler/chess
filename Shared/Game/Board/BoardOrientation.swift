import CoreGraphics

struct BoardOrientation {
    let isFlipped: Bool

    func visualFile(_ file: Int) -> Int {
        isFlipped ? 9 - file : file
    }

    func visualRow(_ row: Int) -> Int {
        isFlipped ? row : 9 - row
    }

    func logicalRow(y: CGFloat, fieldSize: CGFloat) -> Int {
        isFlipped ? Int(1 + y / fieldSize) : Int(9 - y / fieldSize)
    }

    func logicalFile(x: CGFloat, fieldSize: CGFloat) -> Int {
        isFlipped ? Int(9 - x / fieldSize) : Int(1 + x / fieldSize)
    }

    var deltaRowMultiplier: Int { isFlipped ? 1 : -1 }
    var deltaFileMultiplier: Int { isFlipped ? -1 : 1 }
}
