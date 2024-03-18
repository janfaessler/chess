//
//  ResultView.swift
//  SwiftChess
//
//  Created by Jan Fässler on 17.03.2024.
//

import SwiftUI

struct ResultView: View {
    
    let model:ResultModel
    
    init (_ model: ResultModel) {
        self.model = model
    }

    var body: some View {
        
        if model.shouldDisplay() {
            ZStack {
                RoundedRectangle(cornerSize: CGSize(width: 30, height: 30))
                    .fill(.background)
                VStack {
                    Text(model.getResultText())
                        .bold()
                        .font(.largeTitle)
                    if model.shouldDisplayExplenation() {
                        Text(model.getExplenation())
                    }
                }
            }.frame(width: 200, height: 75)
                .shadow(radius: 10)
        }
    }

}

#Preview {
    ResultView(ResultModel(.DrawBy50MoveRule))
}
