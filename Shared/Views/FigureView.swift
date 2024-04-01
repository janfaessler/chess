import SwiftUI

struct FigureView: View {
    let fieldSize:CGFloat
    let figureType:PieceType
    let figureColor:PieceColor

    @State var x:CGFloat? = 0
    @State var y:CGFloat? = 0
    
    init(size: CGFloat, type:PieceType, color:PieceColor) {
        fieldSize = size
        self.figureType = type
        self.figureColor = color
    }
    
    var body: some View {
        Image(getImageName())
            .resizable()
            .frame(width: fieldSize, height: fieldSize, alignment: .topLeading)
    }

    func getImageName() -> String {
        return "\(figureColor)_\(figureType)"
    }
    
}
