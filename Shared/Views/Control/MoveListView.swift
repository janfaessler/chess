import SwiftUI

struct MoveListView: View {
    
    @ObservedObject var model:ControlModel
    @Namespace var bottomID

    var body: some View {

        ScrollView {
            ScrollViewReader { scrollView in
                LazyVGrid(columns: model.moveListColumns, alignment: .leading) {
                        ForEach(Array(model.moves.enumerated()), id: \.element.id) { index, move in
                            if model.isNewRow(index) {
                                Text(model.getRowDescriptionText(index))
                            }
                            
                            MoveView(model: model, index: index) {
                                model.goToMove(index + 1)
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
