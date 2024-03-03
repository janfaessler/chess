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
            .onTapGesture {
                board.setFocus(figure)
            }
    }
    
    func onDragChanged(_ gesture: DragGesture.Value) {
        board.clearFocus()
        setOffset(x: gesture.translation.width, y: gesture.translation.height)
    }
    
    func onDragEnd(_ gesture: _ChangedGesture<DragGesture>.Value) {
        let row = calculateDeltaRow(gesture.translation.height)
        let file = calculateDeltaFile(gesture.translation.width)

        board.move(figure: figure, deltaRow: row, deltaFile: file)
        resetOffset()
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
