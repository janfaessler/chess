import SwiftUI

class FigureModel : Identifiable, ObservableObject {
    
    let id:String = UUID().uuidString
    
    @Published var x:CGFloat? = 0
    @Published var y:CGFloat? = 0
    @Published var zIndex:Double = 0
    @Published var row:Int = 0
    @Published var file:Int = 0
    
    private let figure:any ChessFigure
    let board:BoardModel
    
    init(_ figure:any ChessFigure, board:BoardModel) {
        self.figure = figure
        self.row = figure.getRow()
        self.file = figure.getFile()
        self.board = board
    }
    
    func onDragEnd(_ gesture: _ChangedGesture<DragGesture>.Value, fieldSize:CGFloat) {
        let row = calculateDeltaRow(gesture.translation.height, fieldSize: fieldSize)
        let file = calculateDeltaFile(gesture.translation.width, fieldSize: fieldSize)
        try? board.move(figure: self, deltaRow: row, deltaFile: file)
        resetOffset()
        zIndex = 0
    }

    func move(row:Int, file:Int) {
        figure.move(row: row, file: file)
        self.row = row
        self.file = file
    }
    
    func getMove(deltaRow:Int, deltaFile:Int) -> Move? {
        let moveToRow = row + deltaRow;
        let moveToFile = file + deltaFile;
        let moves = figure.getPossibleMoves();
        
        if figure.getType() == .king {
            if figure.hasMoved() == false && moveToFile < King.CastleQueensidePosition {
                return figure.createMove(moveToRow, King.CastleQueensidePosition, .Castle)
            }
            if figure.hasMoved() == false && moveToFile > King.CastleKingsidePosition {
                return figure.createMove(moveToRow, King.CastleKingsidePosition, .Castle)
            }
        }
        
        return moves.first(where:{ $0.row == moveToRow && $0.file == moveToFile })
    }
    
    func setFocus() {
        board.setFocus(self)
    }
    
    func clearFocus() {
        board.clearFocus()
    }
    
    func getColor() -> PieceColor {
        return figure.getColor()
    }
    
    func getType() -> PieceType {
        return figure.getType()
    }
    
    func getFigure() -> any ChessFigure {
        return figure
    }
    
    func calculateDeltaRow(_ height:CGFloat, fieldSize:CGFloat) -> Int {
        return Int(round(height / fieldSize)) * -1
    }
    
    func calculateDeltaFile(_ width:CGFloat, fieldSize:CGFloat) -> Int {
        return Int(round(width / fieldSize))
    }
    
    func onDragChanged(_ gesture: DragGesture.Value) {
        clearFocus()
        setOffset(x: gesture.translation.width, y: gesture.translation.height)
        zIndex = 1
    }

    func resetOffset() {
        setOffset(x: nil, y: nil)
    }
    
    func getOffsetX(fieldSize:CGFloat) -> CGFloat {
        return (x ?? 0) + calcOffset(forLine: file, fieldSize: fieldSize)
    }
    
    func getOffsetY(fieldSize:CGFloat) -> CGFloat {
        return  (y ?? 0) + calcOffset(forLine: 9 - row, fieldSize: fieldSize)
    }
    
    func setOffset(x:CGFloat?, y:CGFloat?) {
        self.x = x
        self.y = y
    }
    
    func calcOffset(forLine:Int, fieldSize:CGFloat) -> CGFloat {
        return fieldSize * CGFloat(forLine - 1)
    }
}
