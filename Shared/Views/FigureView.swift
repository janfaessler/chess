//
//  FigureView.swift
//  SwiftChess
//
//  Created by Jan Fässler on 15.11.21.
//
import SwiftUI

struct FigureView: View {
    
    let board:Board
    let fieldSize:CGFloat

    @ObservedObject var figure:Figure

    @State var x:CGFloat? = 0
    @State var y:CGFloat? = 0
    
    init(size: CGFloat, figure:Figure, board:Board) {
        fieldSize = size
        self.figure = figure
        self.board = board
    }
    
    var body: some View {
        Image(getImageName())
            .resizable()
            .frame(width: fieldSize, height: fieldSize, alignment: .topLeading)
            .offset(x: getOffsetX(), y: getOffsetY())
            .gesture(
                DragGesture()
                    .onChanged(onDragChanged)
                    .onEnded(onDragEnd)
                )
    }
    
    func onDragChanged(_ gesture: DragGesture.Value) {
        setOffset(x: gesture.translation.width, y: gesture.translation.height)
    }
    
    func onDragEnd(_ gesture: _ChangedGesture<DragGesture>.Value) {
        let row = getRow(gesture.translation.height)
        let file = getFile(gesture.translation.width)
        
        if (isMovePossible(row, file)) {
            moveTo(row, file)
        }
        
        resetOffset()
    }
    
    func isMovePossible(_ row: Int, _ file: Int) -> Bool {
        return isInBoard(row, file) && board.IsMoveLegal(peace: figure, toRow: row, toFile: file)
    }
    
    func moveTo(_ row: Int, _ file: Int) {
        figure.move(row: row, file: file)
        board.move(figure: figure, toRow: row, toFile: file)
    }
    
    func isInBoard(_ rowDelta: Int, _ fileData: Int) -> Bool {
        let range = 1...8
        return range ~= (figure.row + rowDelta) && range ~= (figure.file + fileData)
    }

    func getRow(_ height:CGFloat) -> Int {
        return Int(round(height / fieldSize)) * -1
    }
    
    func getFile(_ width:CGFloat) -> Int {
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
    
    func getImageName() -> String {
        return "\(getColor())_\(getPiece())"
    }
    
    func getColor() -> String {
        return "\(figure.color)"
    }
    
    func getPiece() -> String {
        return "\(figure.type)"
    }
}
