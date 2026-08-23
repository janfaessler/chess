import SwiftUI

struct GameView: View {
    private let controlMinWidth: CGFloat = 300
    private let controlMaxWidth: CGFloat = 400

    @State private var model: ControlModel

    init(_ game: GameData, settings: EngineSettings) {
        _model = State(wrappedValue: ControlModel(game, settings: settings))
    }

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .top, spacing: 0) {
                BoardView(model: model.board)
                    .frame(width: boardSize(geo),
                           height: boardSize(geo))

                ControlView(model: model)
                    .frame(minWidth: controlMinWidth, maxWidth: controlMaxWidth)
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

    private func boardSize(_ geo: GeometryProxy) -> CGFloat {
        min(geo.size.width - controlMinWidth, geo.size.height)
    }
}
