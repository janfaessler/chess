//
//  BoardView.swift
//  SwiftChess
//
//  Created by Jan Fässler on 13.12.21.
//

import SwiftUI

struct BoardView: View {
    let fieldSize:CGFloat
    @ObservedObject var model =  Board()
    
    init(_ size:CGFloat) {
        fieldSize = size
        model.addFigures()
    }
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            BoardBackgroundView(light: Color(red: 0.8, green: 0.8, blue: 0.5), dark: .brown, size: fieldSize)
            ForEach(model.figures) { figure in
                FigureView(size: fieldSize, figure: figure, board: model)
            }
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(100)
    }
}
