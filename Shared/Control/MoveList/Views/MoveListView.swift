import SwiftUI

struct MoveListView: View {
    
    @ObservedObject var model:MoveListModel
    @Namespace var topiD
    @Namespace var bottomID

    var body: some View {
        ScrollView {
            Spacer().id(topiD)
            LineView(model: model, line: model.list)
                .padding(10)
            Spacer().id(bottomID)
        }
    }
}
