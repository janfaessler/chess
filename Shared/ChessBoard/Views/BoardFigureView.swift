import SwiftUI

struct BoardFigureView: View {

    let fieldSize:CGFloat
    @ObservedObject var figure:FigureModel
    
    var body: some View {
        FigureView(size: fieldSize, type: figure.getType(), color: figure.getColor())
            .zIndex(figure.zIndex)
            .offset(x: figure.getOffsetX(fieldSize: fieldSize), y: figure.getOffsetY(fieldSize: fieldSize))
            .gesture(
                DragGesture()
                    .onChanged(figure.onDragChanged)
                    .onEnded { gesture in figure.onDragEnd(gesture, fieldSize: fieldSize) }
                )
            .onTapGesture {
                figure.setFocus()
            }
    }
    

}
