import Foundation

class FigureModel : Identifiable, ObservableObject {
    
    let id:String = UUID().uuidString
    
    @Published var row:Int = 0
    @Published var file:Int = 0
    
    private let figure:any ChessFigure

    init(type:PieceType, color: PieceColor, row:Int, file:Int) {
        figure = Figure.create(type: type, color: color, row: row, file: file)
    }
    
    init(_ figure:any ChessFigure) {
        self.figure = figure
        self.row = figure.getRow()
        self.file = figure.getFile()
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
            if figure.hasMoved() == false && moveToFile < King.LongCastlePosition {
                return figure.createMove(moveToRow, King.LongCastlePosition, .Castle)
            }
            if figure.hasMoved() == false && moveToFile > King.ShortCastlePosition {
                return figure.createMove(moveToRow, King.ShortCastlePosition, .Castle)
            }
        }
        
        return moves.first(where:{ $0.row == moveToRow && $0.file == moveToFile })
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
}
