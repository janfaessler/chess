//
//  FigureViewModel.swift
//  SwiftChess
//
//  Created by Jan Fässler on 13.12.21.
//

import SwiftUI
import Foundation

class Figure : Identifiable, ObservableObject {
    let id:String = UUID().uuidString
    
    let type:PieceType
    let color:PieceColor
        
    @Published var row:Int = 0
    @Published var file:Int = 0
    
    init(type:PieceType, color: PieceColor, row:Int, file:Int) {
        self.type = type
        self.color = color
        self.row = row
        self.file = file
    }
    
    func move(row:Int, file:Int) {
        self.row =  self.row + row
        self.file = self.file + file
    }
}
