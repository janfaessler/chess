import SwiftUI

struct LineView: View {
    
    var model:MoveListModel
    var line:[MovePairModel]
    
    var body: some View {
        Grid {
            if model.moveCount > 0 {
                ForEach(line, id: \.moveNumber) { movePair in
                    GridRow {
                        MovePairView(model: model, pair: movePair)
                    }
                    
                    if movePair.hasVariations(.white) {
                        GridRow {
                            VariationView(model: model, move: movePair.white!)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.gridCellColumns(3)
                    }
                   
                    if movePair.hasVariations(.black) {
                        GridRow {
                            VariationView(model: model, move: movePair.black!)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.gridCellColumns(3)
                    }
                }
            }
        }    }
}
