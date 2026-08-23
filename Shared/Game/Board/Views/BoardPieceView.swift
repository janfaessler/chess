import SwiftUI

struct BoardPieceView: View {

    let fieldSize: CGFloat
    @Bindable var piece: PieceModel

    var body: some View {
        PieceView(size: fieldSize, type: piece.type, color: piece.color)
            .zIndex(piece.zIndex)
            .offset(x: piece.getOffsetX(fieldSize: fieldSize), y: piece.getOffsetY(fieldSize: fieldSize))
            .gesture(
                DragGesture()
                    .onChanged(piece.onDragChanged)
                    .onEnded { gesture in piece.onDragEnd(gesture, fieldSize: fieldSize) }
                )
            .onTapGesture {
                piece.setFocus()
            }
            .accessibilityElement()
            .accessibilityIdentifier("figure-\(piece.squareInfo)")
            .accessibilityAddTraits(.isButton)
    }
}
