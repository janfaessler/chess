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
                        LineView(model: model, line: move.getVariation(variation)!.all)
                            .padding(10)
                    }
                }
            }
        }
    }
}
