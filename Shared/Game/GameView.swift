import SwiftUI

struct GameView: View {
    let game: PgnGame
    @State private var model: ControlModel
    
    init(_ game: PgnGame) {
        self.game = game
        _model = State(wrappedValue: ControlModel(game))
    }

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .top, spacing: 0) {
                BoardView(model: model.board)
                    .frame(width: model.getBoardSize(geo),
                           height: model.getBoardSize(geo))
                
                ControlView(model: model)
                    .frame(minWidth: 300, maxWidth: 400)
                    .background(.clear)
            }
            .focusable()
            .focusEffectDisabled()
            .task { model.start() }
            .onKeyPress { press in
                if press.key == .upArrow {
                    model.moveList.start()
                }
                if press.key == .rightArrow {
                    model.moveList.forward()
                }
                if press.key == .leftArrow {
                    model.moveList.back()
                }
                if press.key == .downArrow {
                    model.moveList.end()
                }
                return .handled
            }
        }
    }
}
