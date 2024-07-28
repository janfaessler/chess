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
                        VStack {
                            ForEach(move.getVariation(variation), id: \.moveNumber) { row in
                                VStack {
                                    HStack {
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
                        }.padding(10)
                    }
                }
            }
        }
    }
}
