import SwiftUI

struct PromotionChooseView: View {
    
    var board:BoardModel
    let fieldSize:CGFloat
    
    var body: some View {
        
        if board.shouldShowPromotionView {
            
            ZStack(alignment: .topLeading)  {
                Rectangle()
                    .fill(.gray)
                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    .accessibilityElement()
                    .accessibilityIdentifier("promotion-picker")

                VStack(alignment: .leading, spacing: 0) {

                    PieceView(size: fieldSize, type: .queen, color: board.promotionColor)
                        .onTapGesture { try? board.doPromote(.queen) }
                        .accessibilityElement()
                        .accessibilityIdentifier("promote-queen")
                        .accessibilityAddTraits(.isButton)
                    PieceView(size: fieldSize, type: .knight, color: board.promotionColor)
                        .onTapGesture { try? board.doPromote(.knight) }
                        .accessibilityElement()
                        .accessibilityIdentifier("promote-knight")
                        .accessibilityAddTraits(.isButton)
                    PieceView(size: fieldSize, type: .rook, color: board.promotionColor)
                        .onTapGesture { try? board.doPromote(.rook) }
                        .accessibilityElement()
                        .accessibilityIdentifier("promote-rook")
                        .accessibilityAddTraits(.isButton)
                    PieceView(size: fieldSize, type: .bishop, color: board.promotionColor)
                        .onTapGesture { try? board.doPromote(.bishop) }
                        .accessibilityElement()
                        .accessibilityIdentifier("promote-bishop")
                        .accessibilityAddTraits(.isButton)
                }
            }
            .frame(width: fieldSize, height: fieldSize * 4)
            .offset(x: getOffsetX(), y: getOffsetY())
        }
        
    }

    func getOffsetX() -> CGFloat {
        guard let move = board.moveToPromote else { return 0 }
        return calcOffset(move.file)
    }

    func getOffsetY() -> CGFloat {
        guard let move = board.moveToPromote else { return 0 }
        let correction = move.color == .white ? -7 : 4
        return calcOffset(move.row + correction)
    }
    
    func calcOffset(_ offset:Int) -> CGFloat {
        return fieldSize * CGFloat(offset - 1)
    }
}
