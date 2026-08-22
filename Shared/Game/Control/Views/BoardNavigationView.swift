import SwiftUI

struct BoardNavigationView: View {
    var model: ControlModel
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                model.board.toggleOrientation()
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title3)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.borderless)
            .background(.quaternary, in: .circle)
            .help("Flip board")
            .accessibilityIdentifier("nav-flip")

            Button {
                model.moveList.start()
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.title3)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.borderless)
            .background(.quaternary, in: .circle)
            .help("Jump to start")
            .accessibilityIdentifier("nav-start")
            
            Button {
                model.moveList.back()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.borderless)
            .background(.quaternary, in: .circle)
            .help("Previous move")
            .accessibilityIdentifier("nav-back")
            
            Spacer()
            
            Button {
                model.moveList.forward()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.borderless)
            .background(.quaternary, in: .circle)
            .help("Next move")
            .accessibilityIdentifier("nav-forward")
            
            Button {
                model.moveList.end()
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.title3)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.borderless)
            .background(.quaternary, in: .circle)
            .help("Jump to end")
            .accessibilityIdentifier("nav-end")
        }
    }
}
