import SwiftUI

struct BoardView: View {

    @Bindable var model: BoardModel

    var body: some View {
        GeometryReader { geo in
            let fieldSize = geo.size.width / 8
            ZStack (alignment: .topLeading) {
                BoardBackgroundView(orientation: model.orientation)

                RightClickOverlay(
                    fieldSize: fieldSize,
                    orientation: model.orientation,
                    onHighlightSquare: { model.toggleUserHighlight(square: $0) },
                    onArrowDrawn: { model.toggleUserArrow(from: $0, to: $1, color: $2) }
                )
                .frame(width: fieldSize * 8, height: fieldSize * 8)

                ForEach(Array(model.allHighlights.enumerated()), id: \.offset) { _, highlight in
                    SquareHighlightView(highlight: highlight, fieldSize: fieldSize, orientation: model.orientation)
                }

                ForEach(model.figures, id: \.id ) { figure in
                    BoardFigureView(fieldSize: fieldSize, figure: figure)
                }

                ForEach(model.getLegalMoves()) { move in
                    MoveIndicatorView(move: move, fieldSize: fieldSize, orientation: model.orientation)
                        .onTapGesture { model.playFocusFigureMove(move) }
                }

                BoardArrowsView(arrows: model.allArrows, fieldSize: fieldSize, orientation: model.orientation)

                PromotionChooseView(board: model, fieldSize: fieldSize)

                ResultView(model: model.result)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture { location in
                model.moveFocusFigureTo(location, fieldSize: fieldSize)
            }
        }
    }
}

#Preview {
    BoardView(model: BoardModel())
}
