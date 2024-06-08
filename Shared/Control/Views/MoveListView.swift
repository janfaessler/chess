import SwiftUI

struct MoveListView: View {
    
    @ObservedObject var model:ControlModel
    @Namespace var bottomID

    var body: some View {

        ScrollView {
            ScrollViewReader { scrollView in
                LazyVGrid(columns: model.moveListColumns, alignment: .leading) {
                    ForEach(model.moves, id: \.id) { move in
                        if move.move.piece.getColor() == .white {
                            Text(model.getRowDescriptionText(move.id))
                        }
                        
                        MoveView(model: model, id: move.id) {
                            model.goToMove(move.id)
                        }
                    }
                    
                    Spacer().id(bottomID)
                }
                .padding(10)
                .onChange(of: model.moves.count) {
                    scrollView.scrollTo(bottomID, anchor: .top)
                }
            }
        }

    }
}
