import SwiftUI

struct VariationMoveView: View {
    @ObservedObject var model:MoveListModel
    @ObservedObject var move:MoveContainer
    
    var body: some View {
        Button {
            model.goToMove(move)
        } label: {
            Text("\(move.move)")
        }
        .buttonStyle(.plain)
        
        if move.hasVariations() {
            Text("(")
            VariationView(model: model, move: move)
            Text(")")
        }
    }
}
