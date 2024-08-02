import SwiftUI

struct MovePairView: View {
    @ObservedObject var model:MoveListModel
    @ObservedObject var pair:MovePairModel
    
    var body: some View {
        Text("\(pair.moveNumber).")
            .frame(minWidth: 20)
        if pair.hasWhiteMoved() {
            MoveView(model: model, move: pair.white!) {
                model.goToMove(pair.white!)
            }
        } else {
            VStack {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.clear)
                Text("...")
            }
        }

        if pair.hasBlackMoved() {
            MoveView(model: model, move: pair.black!) {
                model.goToMove(pair.black!)
            }
        } else {
            Rectangle()
                .frame(maxWidth: .infinity)
                .foregroundColor(.clear)
        }
    }
}
