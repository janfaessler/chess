import SwiftUI
import SwiftChessCore

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

                        if let white = movePair.white, white.hasVariations() {
                            VariationView(
                                model: model,
                                move: white,
                                nestingLevel: nestingLevel + 1
                            )
                            .padding(.leading, 8)
                        }

                        if let black = movePair.black, black.hasVariations() {
                            VariationView(
                                model: model,
                                move: black,
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
