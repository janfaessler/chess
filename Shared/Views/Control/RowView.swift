import SwiftUI

struct RowView: View {
    let index:Int
    let width:CGFloat
    let positions:ArraySlice<String>
    let highlight:PieceColor?
    init(_ index:Int, positions: ArraySlice<String>, width:CGFloat, highlight:PieceColor?) {
        self.index = index
        self.positions = positions
        self.width = width
        self.highlight = highlight
    }
    var body: some View {
        HStack {
            Text("\(index).")
                .frame(width: width / 4)
            if positions.first != nil {
                MoveView(positions.first!, width: width / 3, highlight: highlight == .white)
            }
            Spacer()
            if positions.last != nil && positions.first! != positions.last! {
                MoveView(positions.last!, width: width / 3, highlight: highlight == .black)
            }
        }
        .frame(width: CGFloat(width), height: 20)    }
}

#Preview {
    RowView(1, positions: ["a4", "a5"], width:200, highlight: nil)
}
