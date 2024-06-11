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
                                Text("\(row.moveNumber).")
                                MoveView(model: model, move: row.white) {
                                    model.goToMove(row.white)
                                }
                                if row.hasBlackMoved() {
                                    MoveView(model: model, move: row.black!) {
                                        model.goToMove(row.black!)
                                    }
                                } else {
                                    Rectangle()
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.clear)
                                }
                            }
                            
                            if hasVariations(row.white) {
                                ForEach(getVariations(row.white), id: \.self) { variation in
                                    GridRow {
                                        Text(variation)
                                    }.gridCellColumns(3)
                                }
                            }
                            
                            if hasVariations(row.black) {
                                ForEach(getVariations(row.black), id: \.self) { variation in
                                    GridRow {
                                        Text(variation)
                                    }.gridCellColumns(3)
                                }
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
    
    func hasVariations(_ container:MoveContainer?) -> Bool {
        container?.variations.count ?? 0 > 0
    }
    
    func getVariations(_ container:MoveContainer?) -> [String] {
        var variations:[String] = []
        for v in container!.variations.values {
            variations.append(Array(v).map({ $0.move.info() }).joined(separator: ","))
        }
        return variations
    }
}
