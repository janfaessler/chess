import SwiftUI

struct VariationListView: View {
    @ObservedObject var model:MoveListModel
    @ObservedObject var movePair:MovePairModel

    var body: some View {
        VStack {
            if movePair.hasVariations(.white) {
                ForEach(movePair.white!.getVariations(), id: \.self) { variation in
                    VariationView(model: model, variation: movePair.white!.getVariation(variation)!, name: getName(variation, color: .white))
                }
            }
            
            if movePair.hasVariations(.black) {
                ForEach(movePair.black!.getVariations(), id: \.self) { variation in
                    VariationView(model: model, variation: movePair.black!.getVariation(variation)!, name: getName(variation, color: .black))
                }
            }
        }.padding(5)
    }
    
    func getName(_ variation:String, color:PieceColor) -> String {
        switch color {
        case .white:
            return "\(movePair.moveNumber). \(variation)"
        case .black:
            return "\(movePair.moveNumber)... \(variation)"
        }
    }
}
