import SwiftUI

struct PromotionChooseView: View {
    
    @ObservedObject var board:BoardModel
    let fieldSize:CGFloat
    
    var body: some View {
        
        if board.shouldShowPromotionView {
            
            ZStack(alignment: .topLeading)  {
                Rectangle()
                    .fill(.gray)
                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    FigureView(size: fieldSize, type: .queen, color: board.promotionColor)
                        .onTapGesture { try? board.doPromote(.queen) }
                    FigureView(size: fieldSize, type: .knight, color: board.promotionColor)
                        .onTapGesture { try? board.doPromote(.knight) }
                    FigureView(size: fieldSize, type: .rook, color: board.promotionColor)
                        .onTapGesture { try? board.doPromote(.rook) }
                    FigureView(size: fieldSize, type: .bishop, color: board.promotionColor)
                        .onTapGesture { try? board.doPromote(.bishop) }
                }
            }
            .frame(width: fieldSize, height: fieldSize * 4)
            .offset(x: getOffsetX(), y: getOffsetY())
        }
        
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
