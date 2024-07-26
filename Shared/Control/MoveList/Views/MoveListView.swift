import SwiftUI

struct MoveListView: View {
    
    @ObservedObject var model:MoveListModel
    @Namespace var topiD
    @Namespace var bottomID

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                Grid {
                    GridRow {
                        Spacer().id(topiD)
                    }.gridCellColumns(3)
                    if model.moveCount > 0 {
                        ForEach(model.rows, id: \.moveNumber) { row in
                            GridRow {
                                RowView(model: model, row: row).id(row.white?.id).id(row.black?.id)
                            }
                            
                            if row.hasWhiteVariations() {
                                GridRow {
                                    VariationView(model: model, move: row.white!)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }.gridCellColumns(3)
                            }
                           
                            if row.hasBlackVariations() {
                                GridRow {
                                    VariationView(model: model, move: row.black!)
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
                .onChange(of: model.rows.count) {
                    scrollView.scrollTo(bottomID, anchor: .top)
                }
                .onChange(of: model.currentMove) {
                    if model.atStartPosition() {
                        scrollView.scrollTo(topiD, anchor: .top)
                    } else {
                        scrollView.scrollTo(model.currentMove?.id, anchor: .top)
                    }
                }
            }
        }
    }
}
