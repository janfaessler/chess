import SwiftUI

struct BoardFigureView: View {
    
    let board:BoardModel
    let fieldSize:CGFloat

    @ObservedObject var figure:FigureModel

    @State var x:CGFloat? = 0
    @State var y:CGFloat? = 0
    @State var zIndex:Double = 0
    
    init(size: CGFloat, figure:FigureModel, board:BoardModel) {
        fieldSize = size
        self.figure = figure
        self.board = board
    }
    
    var body: some View {
        FigureView(size: fieldSize, type: figure.getType(), color: figure.getColor())
            .zIndex(zIndex)
            .offset(x: getOffsetX(), y: getOffsetY())
            .gesture(
                DragGesture()
                    .onChanged(onDragChanged)
                    .onEnded(onDragEnd)
                )
            .onTapGesture {
                board.setFocus(figure)
            }
    }
    
    func onDragChanged(_ gesture: DragGesture.Value) {
        board.clearFocus()
        setOffset(x: gesture.translation.width, y: gesture.translation.height)
        zIndex = 1
    }
    
    func onDragEnd(_ gesture: _ChangedGesture<DragGesture>.Value) {
        let row = calculateDeltaRow(gesture.translation.height)
        let file = calculateDeltaFile(gesture.translation.width)
        try? board.move(figure: figure, deltaRow: row, deltaFile: file)
        resetOffset()
        zIndex = 0
    }

    func calculateDeltaRow(_ height:CGFloat) -> Int {
        return Int(round(height / fieldSize)) * -1
    }
    
    func calculateDeltaFile(_ width:CGFloat) -> Int {
        return Int(round(width / fieldSize))
    }
    
    func resetOffset() {
        setOffset(x: nil, y: nil)
    }
    
    func getOffsetX() -> CGFloat {
        return (x ?? 0) + calcOffset(forLine: figure.file)
    }
    
    func getOffsetY() -> CGFloat {
        return  (y ?? 0) + calcOffset(forLine: 9 - figure.row)
    }
    
    func setOffset(x:CGFloat?, y:CGFloat?) {
        self.x = x
        self.y = y
    }
    
    func calcOffset(forLine:Int) -> CGFloat {
        return fieldSize * CGFloat(forLine - 1)
    }
}
