//
//  ContentView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 07/01/25.
//

import SwiftUI



struct ContentView: View {
    
    @EnvironmentObject
    var appCoordinator: AppCoordinator
    
    @ObservedObject
    private var viewModel: GamesListViewModel
    
    init(viewModel: GamesListViewModel = .init()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
            ZStack(alignment: .bottomLeading) {
                
                MainBackground()
                
                VStack(alignment: .center) {
                    ScrollView {
                        
                        switch viewModel.getRecentGamesStatus {
                        case .success:
                            HStack {
                                Text("Recent Activity")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .padding(.top, 32)
                                    .padding(.horizontal, 8)
                                Spacer()
                            }
                            LastPlayedView(games: viewModel.recentGames)
                                .scaledToFill()
                        case .failure:
                            Text("Error")
                        case .idle, .loading:
                            ProgressView()
                        }
                
                        
                        switch viewModel.getGamesStatus {
                        case .success:
                            HStack(alignment: .center){
                                Text(viewModel.filterType.getName())
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .padding(.top, 32)
                                    .padding(.horizontal, 8)
                                Spacer()
                                
                                
                                Button {
                                    viewModel.gridStyle = viewModel.gridStyle.buttonNextGridSize()
                                } label: {
                                    Image(systemName: viewModel.gridStyle.getGridImage())
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding(.top, 32)
                                        .padding(.horizontal, 16)
                                }
                        

                            }
                            
                            LazyVGrid(columns: returnGridSize(value: viewModel.gridStyle),
                                      alignment: .center) {
                                ForEach(Array(viewModel.games.enumerated()), id: \.offset) { index, game in
                                        GameView(game: game)
                                        .onTapGesture {
                                            appCoordinator.path.append(GameListDestination.GameInfo(id: "\(game.appid)"))
                                        }
                                }
                            }
                                      .padding(.horizontal, 4)
                        case .failure:
                            Text("Error")
                        case .idle, .loading:
                            ProgressView()
                        }
                    }
                    .simultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.prepare()
                                
                                if value > 1.2 || value < 0.8 {
                                    impactFeedback.impactOccurred()
                                }
                            }
                            .onEnded { value in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    if value > 1.2 {
                                        viewModel.gridStyle = viewModel.gridStyle.addOne()
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                        impactFeedback.impactOccurred()
                                    } else if value < 0.8 {
                                        viewModel.gridStyle = viewModel.gridStyle.decOne()
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                        impactFeedback.impactOccurred()
                                    }
                                }
                            }
                    )
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
            .navigationDestination(for: GameListDestination.self) { dest in
                switch dest {
                case .GameInfo(id: let id):
                    GameInfoView(viewModel: GameInfoViewModel(gameId: id))
                }
            }
            .task {
                await viewModel.loadInitialDataIfNeeded(scrollRefresh: false)
            }
    }
    
    private func returnGridSize(value: GridSize) -> [GridItem] {
        return (0...value.rawValue - 1).map({ _ in GridItem(.flexible()) })
    }
}

#Preview {
    ContentView(viewModel: GamesListViewModel())
}



// Adicionar game (fora Steam).
//
