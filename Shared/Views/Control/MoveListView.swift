import SwiftUI

struct MoveListView: View {
    
    @ObservedObject var model:ControlModel
    
    var body: some View {

        LazyVGrid(columns: model.moveListColumns, alignment: .leading) {
                
                ForEach(Array(model.realMoves.enumerated()), id: \.element.id) { index, move in
                    if model.isNewRow(index) {
                        Text(model.getRowDescriptionText(index))
                    }
                    
                    MoveView(model: model, index: index) {
                        model.goToMove(index + 1)
                    }
                }
                Spacer()
        }
        .padding(10)
    }
}
