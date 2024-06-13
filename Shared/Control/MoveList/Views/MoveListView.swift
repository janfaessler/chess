import SwiftUI

struct MoveListView: View {
    
    @ObservedObject var model:MoveListModel
    @Namespace var bottomID

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                Grid {
                    if model.moveCount > 0 {
                        ForEach(model.moves, id: \.moveNumber) { row in
                            GridRow {
                                RowView(model: model, row: row)
                            }
                            
                            if row.hasWhiteVariations() {
                                GridRow {
                                    VariationView(model: model, move: row.white!)
                                }.gridCellColumns(3)
                            }
                           
                            if row.hasBlackVariations() {
                                GridRow {
                                    VariationView(model: model, move: row.black!)
                                }.gridCellColumns(3)
                            }
                        }
                    }
                    GridRow {
                        Spacer().id(bottomID)

                    }.gridCellColumns(3)
                }
                .padding(10)
                .onChange(of: model.moves.count) {
                    scrollView.scrollTo(bottomID, anchor: .top)
                }
            }
        }
    }
    

}
