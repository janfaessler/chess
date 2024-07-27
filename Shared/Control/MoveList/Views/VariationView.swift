import SwiftUI
import WrappingHStack

struct VariationView: View {
    @ObservedObject var model:MoveListModel
    @ObservedObject var move:MoveContainer
    
    var body: some View {
        if move.hasVariations() {
            ZStack {
                Rectangle()
                    .foregroundColor(.black)
                    .cornerRadius(5.0)
                VStack {
                    ForEach(getElements(move), id: \.moveNumber) { row in
                        HStack {
                            RowView(model: model, row: row).id(row.white?.id).id(row.black?.id)
                        }
                    }
                }.padding(10)
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
