import SwiftUI
import os

class BoardModel : ObservableObject {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "BoardModel")
    
    typealias MoveNotification = (String) -> ()
    private var moveNotifcations:[MoveNotification] = []
    
    @Published var figures:[FigureModel] = []
    @Published var focus:FigureModel?
    @Published var result:ResultModel
    @Published var moveToPromote:Move?
    
    private var board:ChessBoard

    init() {
        board = ChessBoard(Fen.loadStartingPosition())
        result = ResultModel(board.getGameState())
        figures = getFigures()
    }
    
    var lightColor:Color {
        Color(red: 0.8, green: 0.8, blue: 0.5)
    }
    var darkColor:Color {
        .brown
    }
    
    func getColor(row: Int, file: Int) -> Color {
        let odd = (row + file) % 2 == 0
        return odd ? lightColor : darkColor
    }
    
    func getTextColor(row: Int, file: Int) -> Color {
        let odd = (row + file) % 2 == 0
        return odd ? darkColor : lightColor
    }
    
    func getFileName(_ file:Int) -> String {
        let field = Field(row: 1, file: file)
        return field.getFileName()
    }
    
    func getRowName(_ row:Int) -> String {
        "\(9-row)"
    }
    
    func move(figure: FigureModel, deltaRow:Int, deltaFile:Int)  throws {
        
        guard figure.getColor() == board.getColorToMove() else {
            logger.error("other player has to move first")
            return
        }
        
        guard let move = figure.getMove(deltaRow: deltaRow, deltaFile: deltaFile) else {
            logger.error("no possible move found")
            return
        }
        
        if move.type == .Promotion {
            moveToPromote = move
        } else {
            try doMove(move)
        }
    }
    
    func doMove(_ move: Move) throws {
        try board.move(move)
        notifyMoveDone(move.info())
        figures = getFigures()
        result = ResultModel(board.getGameState())
    }
    
    func doPromote(_ to:PieceType) throws {
        moveToPromote?.promoteTo = to
        try doMove(moveToPromote!)
        moveToPromote = nil
    }
    
    func getLegalMoves() -> [Move] {
        if focus != nil {
            let moves = board.getPossibleMoves(forPeace: focus!.getFigure())
            return moves
        }
        return []
    }
    
    func setFocus(_ fig: FigureModel) {
        focus = fig
    }
    
    func clearFocus() {
        if focus != nil {
            focus = nil
        }
    }
    
    func shouldShowPromotionView() -> Bool {
        return moveToPromote != nil
    }
    
    func getPosition() -> Position {
        return board.getPosition()
    }
    
    func getMoves() -> [Move] {
        return board.getMoves()
    }
    
    func addMoveListener(_ listener:@escaping MoveNotification) {
        moveNotifcations += [listener]
    }
    
    func updatePosition(_ pos:Position)  {
        board = ChessBoard(pos)
        figures = getFigures()
    }
    
    func moveFocusFigureTo(_ location: CGPoint, fieldSize:CGFloat) {
        let row = Int(9 - location.y / fieldSize)
        let file = Int(1 + location.x / fieldSize)
        try? moveFocusFigureTo(row: row, file: file)
    }
    
    func moveFocusFigureTo(row: Int, file:Int) throws {
        guard let figure = focus else { return }
        let deltarow = row - figure.row
        let deltafile = file - figure.file
        try move(figure: figure, deltaRow: deltarow, deltaFile: deltafile)
        clearFocus()
    }
    
    private func moveAndUpdateModel(_ move: Move) throws {
        try board.move(move)
        figures = getFigures()
        result = ResultModel(board.getGameState())
    }
    
    private func getFigures() -> [FigureModel] {
        let figures = board.getFigures()
        return figures.map({ FigureModel($0, board: self) })
    }
    
    private func notifyMoveDone(_ move:String) {
        for event in moveNotifcations {
            event(move)
        }
    }
}
