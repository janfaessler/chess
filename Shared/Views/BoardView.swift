import SwiftUI

struct BoardView: View {
    let fieldSize:CGFloat
    @ObservedObject var model = BoardModel()
    
    init(_ size:CGFloat) {
        fieldSize = size
    }
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            BoardBackgroundView(light: Color(red: 0.8, green: 0.8, blue: 0.5), dark: .brown, size: fieldSize).onTapGesture {
                model.clearFocus()
            }

            ForEach(model.figures) { figure in
                BoardFigureView(size: fieldSize, figure: figure, board: model)
            }
            
            ForEach(model.getLegalMoves()) { move in
                MoveIndicatorView(move, fieldSize)
            }
            
            PromotionChooseView(model, fieldSize)
            
            ResultView(model.result)
                .frame(width: fieldSize * 8, height: fieldSize * 8)
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(100)
    }
}
