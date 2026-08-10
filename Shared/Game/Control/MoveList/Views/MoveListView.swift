import SwiftUI

struct MoveListView: View {
    
    var model: MoveListModel
    @Namespace var topiD
    @Namespace var bottomID

    var body: some View {
        ScrollView {
            Spacer().id(topiD)
            LineView(model: model, line: model.lineModel)
                .padding(10)
            Spacer().id(bottomID)
        }
    }
}
