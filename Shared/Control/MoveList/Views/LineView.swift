import SwiftUI

struct LineView: View {
    
    @ObservedObject var model:MoveListModel
    var line:[MovePairModel]
    
    var body: some View {
        Grid(verticalSpacing: 2.5) {
            if model.moveCount > 0 {
                ForEach(line, id: \.moveNumber) { movePair in
                    GridRow {
                        MovePairView(model: model, pair: movePair)
                    }
                    if model.shouldShowVariationList(movePair) {
                        GridRow {
                            VariationListView(model: model, movePair: movePair)
                        }.gridCellColumns(3)
                    }
                }
            }
        }
    }
}
