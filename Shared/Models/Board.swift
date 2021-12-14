//
//  BoardViewModel.swift
//  SwiftChess
//
//  Created by Jan Fässler on 13.12.21.
//

import SwiftUI

class Board : ObservableObject {
    @Published var figures:[Figure] = []
    
    var colorToMove:PieceColor = .white
    
    func move(figure: Figure, toRow: Int, toFile: Int) {
        print("move called")
    }
    
    func IsMoveLegal(peace: Figure, toRow:Int, toFile:Int) -> Bool {
        print("IsMoveLegal called")
        return true
    }
    
    func addFigures() {
        let pos = Fen.load("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
        figures.append(contentsOf: pos.figures)
    }
}
