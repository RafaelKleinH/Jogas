//
//  SearchView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 13/08/25.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject
    var appCoordinator: AppCoordinator
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
                    SearchItemView(game: game)
                        .padding(.bottom, 8)
                        .onTapGesture {
                            appCoordinator.path.append(GameListDestination.GameInfo(id: "\(game.appid)"))
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
