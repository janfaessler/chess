import SwiftUI

struct BoardView: View {
    let fieldSize:CGFloat
    @ObservedObject var model:BoardModel
    
    init(_ size:CGFloat, board:BoardModel) {
        fieldSize = size / 8
        model = board
    }
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            BoardBackgroundView(size: fieldSize, board: model)
                .onTapGesture { location in
                    model.moveFocusFigureTo(location, fieldSize: fieldSize)
                }


            ForEach(model.figures) { figure in
                BoardFigureView(fieldSize: fieldSize, figure: figure)
            }
            
            ForEach(model.getLegalMoves()) { move in
                MoveIndicatorView(move, fieldSize)
                    .onTapGesture {
                        try? model.moveFocusFigureTo(row: move.row, file: move.file)
                    }
            }
            
            PromotionChooseView(model, fieldSize)
            
            ResultView(model: model.result)
                .frame(width: fieldSize * 8, height: fieldSize * 8)
        }
    }
}

#Preview {
    BoardView(100, board:BoardModel())
}
