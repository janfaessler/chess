import SwiftUI
import SwiftChessCore

@Observable
class FigureModel: Identifiable {

    let id: String = UUID().uuidString

    var x: CGFloat? = 0
    var y: CGFloat? = 0
    var zIndex: Double = 0
    var row: Int = 0
    var file: Int = 0
    var orientation: BoardOrientation

    private let figure: any ChessFigure
    private let onEvent: (FigureEvent) -> Void

    init(
        _ figure: any ChessFigure,
        orientation: BoardOrientation,
        onEvent: @escaping (FigureEvent) -> Void
    ) {
        self.figure = figure
        self.row = figure.row
        self.file = figure.file
        self.orientation = orientation
        self.onEvent = onEvent
    }

    func onDragEnd(_ gesture: DragGesture.Value, fieldSize: CGFloat) {
        let dRow = calculateDeltaRow(gesture.translation.height, fieldSize: fieldSize)
        let dFile = calculateDeltaFile(gesture.translation.width, fieldSize: fieldSize)
        onEvent(.moved(figure: self, deltaRow: dRow, deltaFile: dFile))
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
        onEvent(.focusSet(figure: self))
    }

    func clearFocus() {
        onEvent(.focusCleared)
    }

    var color: PieceColor {
        figure.color
    }

    var type: PieceType {
        figure.type
    }

    var square: String {
        Field(row: row, file: file).info
    }

    func getFigure() -> any ChessFigure {
        figure
    }

    func calculateDeltaRow(_ height: CGFloat, fieldSize: CGFloat) -> Int {
        Int(round(height / fieldSize)) * orientation.deltaRowMultiplier
    }

    func calculateDeltaFile(_ width: CGFloat, fieldSize: CGFloat) -> Int {
        Int(round(width / fieldSize)) * orientation.deltaFileMultiplier
    }

    func resetOffset() {
        setOffset(x: nil, y: nil)
    }

    func getOffsetX(fieldSize: CGFloat) -> CGFloat {
        (x ?? 0) + calcOffset(forLine: orientation.visualFile(file), fieldSize: fieldSize)
    }

    func getOffsetY(fieldSize: CGFloat) -> CGFloat {
        (y ?? 0) + calcOffset(forLine: orientation.visualRow(row), fieldSize: fieldSize)
    }

    func setOffset(x: CGFloat?, y: CGFloat?) {
        self.x = x
        self.y = y
    }

    func calcOffset(forLine: Int, fieldSize: CGFloat) -> CGFloat {
        fieldSize * CGFloat(forLine - 1)
    }
}
