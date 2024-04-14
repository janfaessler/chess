import SwiftUI

struct PromotionChooseView: View {
    
    @ObservedObject var board:BoardModel
    var fieldSize:CGFloat
    
    init(_ b:BoardModel, _ size:CGFloat) {
        board = b
        fieldSize = size
    }

    var body: some View {
        
        if board.shouldShowPromotionView() {
            
            ZStack(alignment: .topLeading)  {
                Rectangle()
                    .fill(.gray)
                    .frame(width: fieldSize, height: fieldSize * 4)
                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    FigureView(size: fieldSize, type: .queen, color: getColor())
                        .onTapGesture { promote(to: .queen) }
                    FigureView(size: fieldSize, type: .knight, color: getColor())
                        .onTapGesture { promote(to: .knight) }
                    FigureView(size: fieldSize, type: .rook, color: getColor())
                        .onTapGesture { promote(to: .rook) }
                    FigureView(size: fieldSize, type: .bishop, color: getColor())
                        .onTapGesture { promote(to: .bishop) }
                }
            }
            .offset(x: getOffsetX(), y: getOffsetY())
            
        }
        
    }
    
    func promote(to:PieceType) {
        do {
            try board.doPromote(to)
        } catch {}
    }
    
    func getColor() -> PieceColor {
        return board.moveToPromote!.piece.getColor()
    }
    
    func getOffsetX() -> CGFloat {
        return calcOffset(board.moveToPromote!.file)
    }
    
    func getOffsetY() -> CGFloat {
        let correction = board.moveToPromote!.piece.getColor() == .white ? -7 : 4
        return calcOffset(board.moveToPromote!.row + correction)
    }
    
    func calcOffset(_ offset:Int) -> CGFloat {
        return fieldSize * CGFloat(offset - 1)
    }
}