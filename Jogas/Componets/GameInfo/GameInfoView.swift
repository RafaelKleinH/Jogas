//
//  GameInfoView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 13/08/25.
//

import SwiftUI

struct GameInfoView: View {
    @ObservedObject var viewModel: GameInfoViewModel
    
    init(viewModel: GameInfoViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            if let game = viewModel.gameInfo {
                GameView(game: .init(appid: game.appid, name: game.name), cornerRadius: 0)
                
                
                
            } else if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading game information...")
                    Spacer()
                }
            } else {
                VStack {
                    Spacer()
                    Text("Failed to load game information")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        
        .onAppear { Task {
            viewModel.isLoading = true
            await viewModel.getGameDetail(gameId: viewModel.gameId)
            viewModel.isLoading = false
        }
        }
    }
    
}

#Preview {
    GameInfoView(viewModel: GameInfoViewModel(gameId: "202421"))
}
