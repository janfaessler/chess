import SwiftUI

struct RowView: View {
    @ObservedObject var model:MoveListModel
    @ObservedObject var row:RowContainer
    
    var body: some View {
        Text("\(row.moveNumber).")
        MoveView(model: model, move: row.white!) {
            model.goToMove(row.white!)
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
