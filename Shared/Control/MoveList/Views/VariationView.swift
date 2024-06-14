import SwiftUI
import WrappingHStack

struct VariationView: View {
    @ObservedObject var model:MoveListModel
    @ObservedObject var move:MoveContainer
    
    var body: some View {
        if move.hasVariations() {
            WrappingHStack(getElements(move), id: \.self) { row in
                HStack {
                    Text("\(row.moveNumber).")
                    if row.hasWhiteMoved() {
                        VariationMoveView(model: model, move: row.white!)
                    } else {
                        Text("...")
                    }
                    if row.hasBlackMoved() {
                        VariationMoveView(model: model, move: row.black!)
                    }
                }
                
            }
        }
    }
    
    func getElements(_ move:MoveContainer) -> [RowContainer] {
        let key = move.getVariations().first!
        var rows:[RowContainer] = []
        if move.variations.keys.contains(key) {
            for row in move.variations[key]! {
                rows.append(row)
            }
        }
        return rows
    }
}
