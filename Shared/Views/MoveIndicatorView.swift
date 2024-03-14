import SwiftUI

struct MoveIndicatorView: View {
    let size:CGFloat
    let fieldSize:CGFloat
    let move:Move

    init (_ m:Move, _ size:CGFloat) {
        move = m
        self.size = size * 0.25
        self.fieldSize = size

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
        
    }
    
    func getOffsetX() -> CGFloat {
        return calcOffset(forLine: move.file)
    }
    
    func getOffsetY() -> CGFloat {
        return calcOffset(forLine: 9 - move.row)
    }
    
    func calcOffset(forLine:Int) -> CGFloat {
        return fieldSize * CGFloat(forLine - 1) + fieldSize / 2 - size / 2
    }
}
