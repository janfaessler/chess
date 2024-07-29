import SwiftUI

struct MoveListView: View {
    
    @ObservedObject var model:MoveListModel
    @Namespace var topiD
    @Namespace var bottomID

    var body: some View {
        ScrollView {
            Grid {
                GridRow {
                    Spacer().id(topiD)
                }.gridCellColumns(3)
                if model.moveCount > 0 {
                    ForEach(model.list, id: \.moveNumber) { movePair in
                        GridRow {
                            RowView(model: model, row: movePair).id(movePair.white?.id).id(movePair.black?.id)
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
                GridRow {
                    Spacer().id(bottomID)

                }.gridCellColumns(3)
            }
            .padding(10)
        
        }
        
    }
}
