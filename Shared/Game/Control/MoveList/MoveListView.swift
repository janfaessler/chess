import SwiftUI

struct MoveListView: View {
    
    var model: MoveListModel
    @Namespace var topID
    @Namespace var bottomID

    var body: some View {
        ScrollView {
            Spacer().id(topID)
            LineView(model: model, line: model.lineModel, lazy: true)
                .padding(10)
            Spacer().id(bottomID)
        }
    }
}
