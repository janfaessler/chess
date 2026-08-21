import SwiftUI

struct BoardView: View {

    @Bindable var model: BoardModel
    
    var body: some View {
        GeometryReader { geo in
            let fieldSize = geo.size.width / 8
            ZStack (alignment: .topLeading) {
                BoardBackgroundView()
       
                ForEach(model.figures, id: \.id ) { figure in
                    BoardFigureView(fieldSize: fieldSize, figure: figure)
                }
                
                ForEach(model.getLegalMoves()) { move in
                    MoveIndicatorView(move: move, fieldSize: fieldSize)
                        .onTapGesture { model.playFocusFigureMove(move) }
                }
                
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
