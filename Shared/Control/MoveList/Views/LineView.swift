import SwiftUI

struct LineView: View {
    
    @ObservedObject var model:MoveListModel
    var line:LineModel
    
    var body: some View {
        Grid(verticalSpacing: 2.5) {
            if line.count > 0 {
                ForEach(line.all, id: \.moveNumber) { movePair in
                    GridRow {
                        MovePairView(model: model, pair: movePair)
                    }
                    if model.shouldShowVariationList(movePair, color: .white) {
                        GridRow {
                            VariationView(model: model, move: movePair.white!, moveNumber: movePair.moveNumber)
                        }.gridCellColumns(3)
                    }
                    if model.shouldShowVariationList(movePair, color: .black) {
                        GridRow {
                            VariationView(model: model, move: movePair.black!, moveNumber: movePair.moveNumber)
                        }.gridCellColumns(3)
                    }
                }
            }
        }
    }
}
