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
    
    @State private var gridTest: GridSize = .defaultSize
    
    var body: some View {
        NavigationStack {
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
                            
                            LazyVGrid(columns: returnGridSize(value: gridTest),
                                      alignment: .center) {
                                ForEach(Array(viewModel.games.enumerated()), id: \.offset) { index, game in
                                    NavigationLink(destination: GameInfoView(viewModel: GameInfoViewModel(gameId: "\(game.appid)"))) {
                                        GameView(game: game)
                                            .padding(.bottom, 8)
                                    }
                                    
                                }
                            }
                                      .padding(.horizontal, 4)
                                      .gesture(<#T##gesture: Gesture##Gesture#>)
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
    
    private func returnGridSize(value: GridSize) -> [GridItem] {
        return (0...value.rawValue - 1).map({ _ in GridItem(.flexible()) })
    }
}

#Preview {
    ContentView()
}



// Adicionar game (fora Steam).
//

enum GridSize: Int {
    case small = 4
    case defaultSize = 3
    case large = 2
    case largest = 1
    
    func addOne() -> GridSize {
        switch self {
        case .small:
            return .defaultSize
        case .defaultSize:
            return .large
        case .large:
            return .largest
        case .largest:
            return .largest
        }
    }
    
    func decOne() -> GridSize {
        switch self {
        case .largest:
            return .large
        case .large:
            return .defaultSize
        case .defaultSize:
            return .small
        case .small:
            return .small
        }
    }
}
