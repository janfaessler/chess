import SwiftUI

struct BoardView: View {

    @ObservedObject var model:BoardModel
    
    var body: some View {
        GeometryReader { geo in
            let fieldSize = geo.size.width / 8
            ZStack (alignment: .topLeading) {
                BoardBackgroundView(model: model)
       
                ForEach(model.figures) { figure in
                    BoardFigureView(fieldSize: fieldSize, figure: figure)
                }
                
                ForEach(model.getLegalMoves()) { move in
                    MoveIndicatorView(move: move, fieldSize: fieldSize)
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
    BoardView(model:BoardModel())
}
