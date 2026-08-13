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
                        
                        if showVariations(for: movePair, color: .white) {
                            VariationView(
                                model: model,
                                move: movePair.white!,
                                moveNumber: movePair.moveNumber,
                                nestingLevel: nestingLevel + 1
                            )
                            .padding(.leading, 8)
                        }

                        if showVariations(for: movePair, color: .black) {
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

    private func showVariations(for pair: MovePairModel, color: PieceColor) -> Bool {
        guard let current = model.currentMove else { return false }
        if color == .white {
            guard let white = pair.white else { return false }
            return current == white ? white.hasVariations() : model.isMove(current, childOf: white)
        } else {
            guard let black = pair.black else { return false }
            return current == black ? black.hasVariations() : model.isMove(current, childOf: black)
        }
    }
}
