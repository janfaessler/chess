import SwiftUI
import SwiftChessCore

struct BoardBackgroundView: View {

    let orientation: BoardOrientation

    private let lightColor = Color(red: 0.8, green: 0.8, blue: 0.5)
    private let darkColor = Color.brown

    var body: some View {
        VStack(spacing: 0.0) {
            ForEach(1...8, id: \.self) { rowIndex in
                HStack(spacing: 0.0) {
                    ForEach(1...8, id: \.self) { colIndex in
                        let row = orientation.visualRow(rowIndex)
                        let file = orientation.visualFile(colIndex)
                        ZStack {
                            Rectangle()
                                .fill(fieldColor(row: row, file: file))

                            if rowIndex == 8 {
                                Text(fileName(file))
                                    .fontWeight(.bold)
                                    .font(.largeTitle)
                                    .foregroundStyle(textColor(row: row, file: file))
                                    .padding(3)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            }

                            if colIndex == 1 {
                                Text(rowName(row))
                                    .fontWeight(.bold)
                                    .font(.largeTitle)
                                    .foregroundStyle(textColor(row: row, file: file))
                                    .padding(3)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier("chessboard")
    }

    private func fieldColor(row: Int, file: Int) -> Color {
        (row + file) % 2 == 0 ? lightColor : darkColor
    }

    private func textColor(row: Int, file: Int) -> Color {
        (row + file) % 2 == 0 ? darkColor : lightColor
    }

    private func fileName(_ file: Int) -> String {
        Field(row: 1, file: file).fileName
    }

    private func rowName(_ row: Int) -> String {
        "\(row)"
    }
}
