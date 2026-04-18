import SwiftUI

struct LineView: View {
    
    var model: MoveListModel
    var line: LineModel
    var nestingLevel: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            if line.count > 0 {
                ForEach(line.all, id: \.moveNumber) { movePair in
                    VStack(alignment: .leading, spacing: 1) {
                        Grid(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 0) {
                            GridRow {
                                MovePairView(model: model, pair: movePair)
                            }
                        }
                        
                        if model.shouldShowVariationList(movePair, color: .white) {
                            VariationView(
                                model: model,
                                move: movePair.white!,
                                moveNumber: movePair.moveNumber,
                                nestingLevel: nestingLevel + 1
                            )
                            .padding(.leading, 8)
                        }
                        
                        if model.shouldShowVariationList(movePair, color: .black) {
                            VariationView(
                                model: model,
                                move: movePair.black!,
                                moveNumber: movePair.moveNumber,
                                nestingLevel: nestingLevel + 1
                            )
                            .padding(.leading, 8)
                        }
                    }
                }
            }
        }
    }
}
