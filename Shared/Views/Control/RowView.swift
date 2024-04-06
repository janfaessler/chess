import SwiftUI

struct RowView: View {
    let index:Int
    let positions:ArraySlice<String>
    let highlight:PieceColor?
    init(_ index:Int, positions: ArraySlice<String>, width:CGFloat, highlight:PieceColor?) {
        self.index = index
        self.positions = positions
        self.highlight = highlight
    }
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 5) {
                Text("\(index).")
                    .frame(width: 20)
                if positions.first != nil {
                    MoveView(positions.first!, width: (geo.size.width - 20 - 25) / 2, highlight: highlight == .white)
                }
                if positions.last != nil && positions.first! != positions.last! {
                    MoveView(positions.last!, width: (geo.size.width - 20 - 25) / 2, highlight: highlight == .black)
                }
                Spacer()
            }
            .frame(width: geo.size.width)
        }.frame(height: 20)
    }
}

#Preview {
    RowView(1, positions: ["a4", "a5"], width:200, highlight: nil)
}
