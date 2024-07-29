import SwiftUI

struct VariationView: View {
    @ObservedObject var model:MoveListModel
    @ObservedObject var move:MoveModel
    
    var body: some View {
        if move.hasVariations() {
            VStack {
                ForEach(move.getVariations(), id: \.self) { variation in
                    ZStack {
                        Rectangle()
                            .foregroundColor(.black)
                            .border(.white)
                            .clipShape(.rect(cornerRadius: 10))
                        Grid {
                            ForEach(move.getVariation(variation)!.all, id: \.moveNumber) { movePair in
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
                        }.padding(10)
                    }
                }
            }
        }
    }
}
