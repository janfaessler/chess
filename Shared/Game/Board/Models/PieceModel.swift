import SwiftUI
import SwiftChessCore

@Observable
class PieceModel: Identifiable {

    let id: String = UUID().uuidString

    var x: CGFloat? = 0
    var y: CGFloat? = 0
    var zIndex: Double = 0
    var row: Int = 0
    var file: Int = 0
    var orientation: BoardOrientation

    private let piece: any ChessPiece
    private let onEvent: (PieceEvent) -> Void

    init(
        _ piece: any ChessPiece,
        orientation: BoardOrientation,
        onEvent: @escaping (PieceEvent) -> Void
    ) {
        self.piece = piece
        self.row = piece.row
        self.file = piece.file
        self.orientation = orientation
        self.onEvent = onEvent
    }

    func onDragEnd(_ gesture: DragGesture.Value, fieldSize: CGFloat) {
        let dRow = calculateDeltaRow(gesture.translation.height, fieldSize: fieldSize)
        let dFile = calculateDeltaFile(gesture.translation.width, fieldSize: fieldSize)
        onEvent(.moved(piece: self, deltaRow: dRow, deltaFile: dFile))
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
        return piece.getPossibleMoves().first(where: { $0.row == targetRow && $0.file == targetFile })
    }

    func setFocus() {
        onEvent(.focusSet(piece: self))
    }

    func clearFocus() {
        onEvent(.focusCleared)
    }

    var color: PieceColor {
        piece.color
    }

    var type: PieceType {
        piece.type
    }

    var squareInfo: String {
        Square(row: row, file: file)?.info ?? "??"
    }

    func getPiece() -> any ChessPiece {
        piece
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
