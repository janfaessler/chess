import SwiftUI

@Observable
class FigureModel: Identifiable {
    
    let id: String = UUID().uuidString
    
    var x: CGFloat? = 0
    var y: CGFloat? = 0
    var zIndex: Double = 0
    var row: Int = 0
    var file: Int = 0
    
    private let figure: any ChessFigure
    let board: BoardModel
    
    init(_ figure: any ChessFigure, board: BoardModel) {
        self.figure = figure
        self.row = figure.row
        self.file = figure.file
        self.board = board
    }
    
    func onDragEnd(_ gesture: _ChangedGesture<DragGesture>.Value, fieldSize: CGFloat) {
        let row = calculateDeltaRow(gesture.translation.height, fieldSize: fieldSize)
        let file = calculateDeltaFile(gesture.translation.width, fieldSize: fieldSize)
        board.move(figure: self, deltaRow: row, deltaFile: file)
        resetOffset()
        zIndex = 0
    }

    func onDragChanged(_ gesture: DragGesture.Value) {
        clearFocus()
        setOffset(x: gesture.translation.width, y: gesture.translation.height)
        zIndex = 1
    }

    func getMove(deltaRow: Int, deltaFile: Int) -> Move? {
        let targetRow = row + deltaRow
        let targetFile = file + deltaFile
        return figure.getPossibleMoves().first(where: { $0.row == targetRow && $0.file == targetFile })
    }
    
    func setFocus() {
        board.setFocus(self)
    }
    
    func clearFocus() {
        board.clearFocus()
    }
    
    var color: PieceColor {
        figure.color
    }

    var type: PieceType {
        figure.type
    }

    func getFigure() -> any ChessFigure {
        figure
    }
    
    func calculateDeltaRow(_ height: CGFloat, fieldSize: CGFloat) -> Int {
        Int(round(height / fieldSize)) * -1
    }
    
    func calculateDeltaFile(_ width: CGFloat, fieldSize: CGFloat) -> Int {
        Int(round(width / fieldSize))
    }

    func resetOffset() {
        setOffset(x: nil, y: nil)
    }
    
    func getOffsetX(fieldSize: CGFloat) -> CGFloat {
        (x ?? 0) + calcOffset(forLine: file, fieldSize: fieldSize)
    }
    
    func getOffsetY(fieldSize: CGFloat) -> CGFloat {
        (y ?? 0) + calcOffset(forLine: 9 - row, fieldSize: fieldSize)
    }
    
    func setOffset(x: CGFloat?, y: CGFloat?) {
        self.x = x
        self.y = y
    }
    
    func calcOffset(forLine: Int, fieldSize: CGFloat) -> CGFloat {
        fieldSize * CGFloat(forLine - 1)
    }
}
