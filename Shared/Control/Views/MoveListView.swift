import SwiftUI

struct MoveListView: View {
    
    @ObservedObject var model:ControlModel
    @Namespace var bottomID

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                Grid {
                    if model.moveCount > 0 {
                        ForEach(1...model.moveCount, id: \.self) { i in
                            GridRow {
                                Text("\(i).")
                                if model.hasMoved(i, color: .white) {
                                    MoveView(model: model, id: model.getMove(i, color: .white).id) {
                                        model.goToMove(model.getMove(i, color: .white).id)
                                    }
                                }
                                if model.hasMoved(i, color: .black) {
                                    MoveView(model: model, id: model.getMove(i, color: .black).id) {
                                        model.goToMove(model.getMove(i, color: .black).id)
                                    }
                                } else {
                                    Rectangle()
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.clear)
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
}
