//
//  SearchItemView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 13/08/25.
//

import SwiftUI

struct SearchItemView: View {
    
    let game: SteamGamesResumed
    
    var body: some View {
            HStack(alignment: .center) {
                GameView(game: game)
                    .frame(width: 90)
                
                Text(game.name)
                    .fontWeight(.bold)
                    .padding(.leading)
                
                Spacer()
            }
        
    }
}

#Preview {
    SearchItemView(game: .init(appid: 0, name: "Jogo"))
}
