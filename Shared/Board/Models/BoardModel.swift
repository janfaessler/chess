import SwiftUI
import os

class BoardModel : ObservableObject {
    
    typealias MoveNotification = (String) -> ()
    private var moveNotifcations:[MoveNotification] = []
    
    @Published var figures:[FigureModel] = []
    @Published var focus:FigureModel?
    @Published var result:ResultModel
    @Published var moveToPromote:Move?
    
    private var board:ChessBoard

    init() {
        board = ChessBoard(PositionFactory.startingPosition())
        result = ResultModel(board.getGameState())
        figures = getFigures()
    }
    
    var lightColor:Color {
        Color(red: 0.8, green: 0.8, blue: 0.5)
    }
    var darkColor:Color {
        .brown
    }
    
    var promotionColor: PieceColor {
        moveToPromote!.piece.getColor()
    }
    
    var shouldShowPromotionView:Bool {
        return moveToPromote != nil
    }
    
    func getFieldColor(row: Int, file: Int) -> Color {
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
    
    func move(figure: FigureModel, deltaRow:Int, deltaFile:Int) {
        
        guard figure.getColor() == board.getColorToMove() else {
            return
        }
        
        guard let move = figure.getMove(deltaRow: deltaRow, deltaFile: deltaFile) else {
            return
        }
        
        if move.type == .Promotion {
            moveToPromote = move
        } else {
            try? doMove(move)
        }
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
    
    func getPosition() -> Position {
        return board.getPosition()
    }
    
    func addMoveListener(_ listener:@escaping MoveNotification) {
        moveNotifcations += [listener]
    }
    
    func updatePosition(_ pos:Position)  {
        board = ChessBoard(pos)
        figures = getFigures()
    }
    
    func moveFocusFigureTo(_ location: CGPoint, fieldSize:CGFloat) {
        guard let figure = focus else { return }

        let row = Int(9 - location.y / fieldSize)
        let file = Int(1 + location.x / fieldSize)
        let deltarow = row - figure.row
        let deltafile = file - figure.file
        
        move(figure: figure, deltaRow: deltarow, deltaFile: deltafile)
        clearFocus()
    }
    
    private func doMove(_ move: Move) throws {
        let positionBeforeMove = FenBuilder.create(board.getPosition())
        try board.move(move)
        figures = getFigures()
        result = ResultModel(board.getGameState())
        notifyMoveDone(move, fen: positionBeforeMove)
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
    
    private func notifyMoveDone(_ move:Move, fen:String) {
        let notation = NotationFactory.generate(move, position: FenParser.parse(fen))
        for event in moveNotifcations {
            event(notation)
        }
    }
}
