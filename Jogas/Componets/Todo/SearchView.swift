//
//  SearchView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 13/08/25.
//

import SwiftUI

struct SearchView: View {
    
    let games: [SteamGamesResumed]
    
    public var body: some View {

        ScrollView {
            
            VStack(alignment: .center) {
                
                HStack {
                    Text("Search")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.vertical)
                    Spacer()
                }
                
                    
                ForEach(Array(games.enumerated()), id: \.offset) { index, game in
                    NavigationLink(destination: GameInfoView(viewModel: GameInfoViewModel(gameId: "\(game.appid)"))) {
                        SearchItemView(game: game)
                            .padding(.bottom, 8)
                    }
                }
                
                Spacer()
            }
            .padding()
            .padding(.bottom, 64)
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    SearchView(games: [.init(appid: 0, name: "JOGO")])
}
