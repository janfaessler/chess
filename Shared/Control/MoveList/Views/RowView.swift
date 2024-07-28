import SwiftUI

struct RowView: View {
    @ObservedObject var model:MoveListModel
    @ObservedObject var row:MovePairModel
    
    var body: some View {
        Text("\(row.moveNumber).")
            .frame(minWidth: 20)
        if row.hasWhiteMoved() {
            MoveView(model: model, move: row.white!) {
                model.goToMove(row.white!)
            }
        } else {
            VStack {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.clear)
                Text("...")
            }
        }

        if row.hasBlackMoved() {
            MoveView(model: model, move: row.black!) {
                model.goToMove(row.black!)
            }
        } else {
            Rectangle()
                .frame(maxWidth: .infinity)
                .foregroundColor(.clear)
        }
    }
}
