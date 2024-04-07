import SwiftUI

struct MoveRowView: View {
    let index:Int
    let positions:ArraySlice<String>
    let highlight:PieceColor?
    let model:ControlModel
    init(_ index:Int, width:CGFloat, model:ControlModel) {
        self.index = index
        self.model = model
        positions = model.moves[index...(model.moves.count > index + 1 ? index + 1 : index)]
        highlight = model.currentMove == index + 1 ? .white : (model.currentMove == index + 2 ? .black : nil)
    }
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 5) {
                Text("\(getMoveNumber(index)).")
                    .frame(width: 20)
                if positions.first != nil {
                    MoveView(positions.first!, width: (geo.size.width - 20 - 25) / 2, highlight: highlight == .white) {
                        model.goToMove(index + 1)
                    }
                }
                if positions.last != nil && positions.first! != positions.last! {
                    MoveView(positions.last!, width: (geo.size.width - 20 - 25) / 2, highlight: highlight == .black) {
                        model.goToMove(index + 2)
                    }
                }
                Spacer()
            }
            .frame(width: geo.size.width)
        }.frame(height: 20)
    }
    
    private func getMoveNumber(_ index: Int) -> Int {
        return index / 2 + 1
    }
    
}

