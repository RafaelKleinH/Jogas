//
//  ContentView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 07/01/25.
//

import SwiftUI



struct ContentView: View {
    
    @ObservedObject
    private var viewModel: GamesListViewModel = .init()
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            MainBackground()
            
            VStack(alignment: .center) {
                ScrollView {
                    HStack {
                        Text("Recent Activity")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 32)
                            .padding(.horizontal, 8)
                        Spacer()
                        
                
                    }
                    
                    if !viewModel.recentGames.isEmpty {
                        LastPlayedView(games: viewModel.recentGames)
                            .scaledToFill()
                    } else {
                        ProgressView()
                    }
                    
                    if !viewModel.games.isEmpty {
                        HStack {
                            Text(viewModel.filterType.getName())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 32)
                                .padding(.horizontal, 8)
                            Spacer()
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())],
                                  alignment: .center) {
                            ForEach(Array(viewModel.games.enumerated()), id: \.offset) { index, game in
                                GameView(game: game)
                                    .padding(.bottom, 8)
                            }
                        }
                                  .padding(.horizontal, 4)
                    }
                }
            }
            
            if viewModel.searching {
                SearchView(games: viewModel.searchedGames)
                    .padding(.top, 32)
                    .ignoresSafeArea(.container, edges: .bottom)
            }
         
            
            BottomButtonStack(filterType: $viewModel.filterType, search: $viewModel.searchText, searching: $viewModel.searching)
                .padding()
                .ignoresSafeArea()
           
        }
        .onAppear {
            Task {
                async let games: Void = viewModel.getGames(filter: viewModel.filterType.rawValue)
                async let recentGames: Void = viewModel.getRecentGames()
                await games
                await recentGames
            }
        }
    }
}

#Preview {
    ContentView()
}
