import SwiftUI

struct BoardBackgroundView: View {
    
    @ObservedObject var model:BoardModel
    @State var lightColor:Color
    @State var darkColor:Color
    
    var fieldSize:CGFloat
    
    init(size: CGFloat, board:BoardModel) {
        lightColor =  Color(red: 0.8, green: 0.8, blue: 0.5);
        darkColor = .brown;
        fieldSize = size;
        model = board;
    }
    
    var body: some View {
        VStack(spacing: 0.0) {
            ForEach(1...8, id: \.self) { row in
                HStack(spacing: 0.0) {
                    ForEach(1...8, id: \.self) { file in
                        self.getRectangle(row: row, file: file, color: getColor(row: row, file: file))
                    }
                }
            }
        }
    }
    
    func getRectangle(row: Int,file: Int, color:Color) -> some View {
        return Rectangle()
            .fill(getColor(row: row, file: file))
            .frame(width: fieldSize, height: fieldSize)
            .onTapGesture { onTab(row: row, file: file) }

    }
    
    func onTab(row: Int, file:Int) {
        try? model.moveFocusFigureTo(row: (9-row), file: file)
    }
    
    func getColor(row: Int, file: Int) -> Color {
        let odd = (row + file) % 2 == 0
        return odd ? lightColor : darkColor
    }
    
}
