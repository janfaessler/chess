import SwiftUI

struct MovePairView: View {
    var model: MoveListModel
    var pair: MovePairModel
    
    var body: some View {
        Text(verbatim: "\(pair.moveNumber).")
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.secondary)
            .frame(width: 32, alignment: .trailing)
        
        if pair.hasWhiteMoved() {
            MoveView(model: model, move: pair.white!) {
                model.goToMove(pair.white!)
            }
            .frame(minWidth: 60, idealWidth: 80, maxWidth: .infinity)
        } else {
            Text("...")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(minWidth: 60, idealWidth: 80, maxWidth: .infinity)
        }

        if pair.hasBlackMoved() {
            MoveView(model: model, move: pair.black!) {
                model.goToMove(pair.black!)
            }
            .frame(minWidth: 60, idealWidth: 80, maxWidth: .infinity)
        } else {
            Color.clear
                .frame(minWidth: 60, idealWidth: 80, maxWidth: .infinity)
        }
    }
}
