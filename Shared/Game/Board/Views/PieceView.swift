import SwiftUI
import SwiftChessCore

struct PieceView: View {
    let fieldSize: CGFloat
    let pieceType: PieceType
    let pieceColor: PieceColor

    init(size: CGFloat, type: PieceType, color: PieceColor) {
        fieldSize = size
        self.pieceType = type
        self.pieceColor = color
    }

    var body: some View {
        Image("\(pieceColor)_\(pieceType)")
            .resizable()
            .frame(width: fieldSize, height: fieldSize, alignment: .topLeading)
    }
}
