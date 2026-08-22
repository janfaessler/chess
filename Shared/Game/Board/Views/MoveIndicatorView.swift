import SwiftUI
import SwiftChessCore

struct MoveIndicatorView: View {
    let size: CGFloat
    let fieldSize: CGFloat
    let move: Move
    let orientation: BoardOrientation

    init(move: Move, fieldSize: CGFloat, orientation: BoardOrientation) {
        self.move = move
        self.size = fieldSize * 0.25
        self.fieldSize = fieldSize
        self.orientation = orientation
    }
    var body: some View {
        
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.9))

            Circle()
                .strokeBorder(.black, lineWidth: 1)
                
        }
        .frame(width: size, height: size, alignment: .center)
        .offset(x: getOffsetX() , y: getOffsetY())
        .accessibilityElement()
        .accessibilityIdentifier("target-\(move.fieldInfo)")
        .accessibilityAddTraits(.isButton)

    }
    
    
    func getOffsetX() -> CGFloat {
        calcOffset(forLine: orientation.visualFile(move.file))
    }

    func getOffsetY() -> CGFloat {
        calcOffset(forLine: orientation.visualRow(move.row))
    }
    
    func calcOffset(forLine:Int) -> CGFloat {
        return fieldSize * CGFloat(forLine - 1) + fieldSize / 2 - size / 2
    }
}
