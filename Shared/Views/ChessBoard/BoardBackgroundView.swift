import SwiftUI

struct BoardBackgroundView: View {
    
    @ObservedObject var model:BoardModel
    
    var fieldSize:CGFloat
    
    init(size: CGFloat, board:BoardModel) {
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
                                .fill(model.getColor(row: row, file: file))
                                .frame(width: fieldSize, height: fieldSize)
                            
                            if row == 8 {
                                Text(model.getFileName(file))
                                    .fontWeight(.bold)
                                    .font(.largeTitle)
                                    .foregroundStyle(model.getTextColor(row: row, file: file))
                                    .padding(3)
                                    .frame(width: fieldSize, height: fieldSize, alignment: .bottomTrailing)
                            }
                            
                            if file == 1 {
                                Text(model.getRowName(row))
                                    .fontWeight(.bold)
                                    .font(.largeTitle)
                                    .foregroundStyle(model.getTextColor(row: row, file: file))
                                    .padding(3)
                                    .frame(width: fieldSize, height: fieldSize, alignment: .topLeading)
                            }
                        }
                    }
                }
            }
        }
    }

}
