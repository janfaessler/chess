import SwiftUI
import os

@Observable
class BoardModel {
    
    typealias MoveNotification = (String) -> ()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "BoardModel")
    private var moveNotifcations: [MoveNotification] = []
    
    var figures: [FigureModel] = []
    var focus: FigureModel?
    var result: ResultModel
    var moveToPromote: Move?
    
    private var board: ChessBoard


    init(board: ChessBoard? = nil) {
        let newBoard = board ?? ChessBoard(PositionFactory.startingPosition())
        self.board = newBoard
        result = ResultModel(newBoard.getGameState())
        figures = getFigures()
    }
    
    
    var lightColor: Color {
        Color(red: 0.8, green: 0.8, blue: 0.5)
    }
    
    var darkColor: Color {
        .brown
    }
    
    var promotionColor: PieceColor {
        moveToPromote!.piece.getColor()
    }
    
    var shouldShowPromotionView: Bool {
        moveToPromote != nil
    }
    
    func getFieldColor(row: Int, file: Int) -> Color {
        let odd = (row + file) % 2 == 0
        return odd ? lightColor : darkColor
    }
    
    func getTextColor(row: Int, file: Int) -> Color {
        let odd = (row + file) % 2 == 0
        return odd ? darkColor : lightColor
    }
    
    func getFileName(_ file: Int) -> String {
        let field = Field(row: 1, file: file)
        return field.getFileName()
    }
    
    func getRowName(_ row: Int) -> String {
        "\(9 - row)"
    }
    
    
    func move(figure: FigureModel, deltaRow: Int, deltaFile: Int) {
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
    
    func doPromote(_ to: PieceType) throws {
        moveToPromote?.promoteTo = to
        try doMove(moveToPromote!)
        moveToPromote = nil
    }
    
    func getLegalMoves() -> [Move] {
        if let focus = focus {
            return board.getPossibleMoves(forPeace: focus.getFigure())
        }
        return []
    }
    
    func setFocus(_ fig: FigureModel) {
        focus = fig
    }
    
    func clearFocus() {
        focus = nil
    }
    
    func getPosition() -> Position {
        self.board.getPosition()
    }
    
    func addMoveListener(_ listener: @escaping MoveNotification) {
        self.moveNotifcations.append(listener)
    }
    
    func updatePosition(_ pos: Position) {
        self.logger.info("BoardModel.updatePosition called - updating \(pos.getFigures().count) figures")
        self.board = ChessBoard(pos)
        let newFigures = self.getFigures()
        self.figures = newFigures  // Explicit assignment to new array
        self.result = ResultModel(self.board.getGameState())
        self.logger.info("BoardModel.updatePosition complete - now have \(self.figures.count) figures")
    }
    
    func moveFocusFigureTo(_ location: CGPoint, fieldSize: CGFloat) {
        guard let figure = self.focus else { return }

        let row = Int(9 - location.y / fieldSize)
        let file = Int(1 + location.x / fieldSize)
        let deltarow = row - figure.row
        let deltafile = file - figure.file
        
        self.move(figure: figure, deltaRow: deltarow, deltaFile: deltafile)
        self.clearFocus()
    }
    
    private func doMove(_ move: Move) throws {
        let positionBeforeMove = FenBuilder.create(self.board.getPosition())
        try self.board.move(move)
        self.figures = self.getFigures()
        self.result = ResultModel(self.board.getGameState())
        self.notifyMoveDone(move, fen: positionBeforeMove)
    }
    
    private func moveAndUpdateModel(_ move: Move) throws {
        try self.board.move(move)
        self.figures = self.getFigures()
        self.result = ResultModel(self.board.getGameState())
    }
    
    private func getFigures() -> [FigureModel] {
        let figures = self.board.getFigures()
        return figures.map { FigureModel($0, board: self) }
    }
    
    private func notifyMoveDone(_ move: Move, fen: String) {
        let notation = NotationFactory.generate(move, position: FenParser.parse(fen))
        for event in self.moveNotifcations {
            event(notation)
        }
    }
}
