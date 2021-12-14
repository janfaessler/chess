//
//  Board.swift
//  SwiftChess
//
//  Created by Jan Fässler on 15.11.21.
//
import SwiftUI
import Foundation

struct BoardBackgroundView: View {
    @State var lightColor:Color
    @State var darkColor:Color
    
    var fieldSize:CGFloat
    
    init(light:Color, dark:Color, size: CGFloat) {
        lightColor = light;
        darkColor = dark;
        fieldSize = size;
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
    }
    
    func getColor(row: Int, file: Int) -> Color {
        let odd = (row + file) % 2 == 0
        return odd ? lightColor : darkColor
    }
}
