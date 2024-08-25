import SwiftUI
import FilePicker

struct ControlView: View {
    
    @ObservedObject var model:ControlModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GamesView(model: model)
            EngineView(lines: model.lines)
            MoveListView(model: model.moveList)
            Spacer()
            CommentView(model: model)
            BoardNavigationView(model: model)
        }
    }
    
    
}

