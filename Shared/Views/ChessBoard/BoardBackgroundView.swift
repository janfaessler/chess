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
                            ZStack {
                                Rectangle()
                                    .fill(getColor(row: row, file: file))
                                    .frame(width: fieldSize, height: fieldSize)
                                    .onTapGesture { onTab(row: row, file: file) }
                                
                                if row == 8 {
                                    Text(getFileName(file))
                                        .fontWeight(.bold)
                                        .font(.largeTitle)
                                        .foregroundStyle(getTextColor(row: row, file: file))
                                        .padding(3)
                                        .frame(width: fieldSize, height: fieldSize, alignment: .bottomTrailing)
                                }
                                
                                if file == 1 {
                                    Text(getRowName(row))
                                        .fontWeight(.bold)
                                        .font(.largeTitle)
                                        .foregroundStyle(getTextColor(row: row, file: file))
                                        .padding(3)
                                        .frame(width: fieldSize, height: fieldSize, alignment: .topLeading)
                                }
                            }
                        }
                    }
                }
            }
    }
    

    
    func onTab(row: Int, file:Int) {
        try? model.moveFocusFigureTo(row: (9-row), file: file)
    }
    
    func getColor(row: Int, file: Int) -> Color {
        let odd = (row + file) % 2 == 0
        return odd ? lightColor : darkColor
    }
    
    func getTextColor(row: Int, file: Int) -> Color {
        let odd = (row + file) % 2 == 0
        return odd ? darkColor : lightColor
    }
    
    func getFileName(_ file:Int) -> String {
        let field = Field(row: 1, file: file)
        return field.getFileName()
    }
    
    func getRowName(_ row:Int) -> String {
        "\(9-row)"
    }
}
