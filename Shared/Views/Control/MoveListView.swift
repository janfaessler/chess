import SwiftUI

struct MoveListView: View {
    let size:CGSize
    
    @ObservedObject var model:ControlModel
    
    init (_ size:CGSize, model:ControlModel) {
        self.size = size
        self.model = model
    }
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Array(stride(from: 0, to: model.moves.count, by: 2)), id: \.self) { index in
                RowView(getMoveNumber(index),
                        positions: getMoveSlice(index),
                        width: size.width,
                        highlight: getHighlightForRow(index))
            }
            Spacer()
        }
        .padding(10)
        .frame(width: size.width, height: size.height)
    }
    
    private func getMoveNumber(_ index: Int) -> Int {
        return index / 2 + 1
    }
    
    private func getMoveSlice(_ index: Int) -> ArraySlice<String> {
        return model.moves[index...(model.moves.count > index + 1 ? index + 1 : index)]
    }
    private func getHighlightForRow(_ index: Int) -> PieceColor? {
        return model.currentMove == index + 1 ? .white : (model.currentMove == index + 2 ? .black : nil)
    }
}


#Preview {
    MoveListView(CGSize(width: 200, height: 500), model: ControlModel())
}
