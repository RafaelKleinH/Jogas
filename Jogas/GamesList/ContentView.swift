//
//  ContentView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 07/01/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @ObservedObject private var viewModel: GamesListViewModel
    
    init(viewModel: GamesListViewModel = .init()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            MainBackground()
            
            mainContentView
            
            searchOverlayView
            
            bottomButtonStack
        }
        .navigationDestination(for: GameListDestination.self, destination: navigationDestination)
        .task {
            await viewModel.loadInitialDataIfNeeded(scrollRefresh: false)
        }
    }
}

// MARK: - Main Content
private extension ContentView {
    var mainContentView: some View {
        VStack(alignment: .center) {
            ScrollView {
                RecentGamesSection(
                    status: viewModel.getRecentGamesStatus,
                    games: viewModel.recentGames
                )
                
                GamesGridSection(
                    status: viewModel.getGamesStatus,
                    filterType: viewModel.filterType,
                    gridStyle: viewModel.gridStyle,
                    games: viewModel.games,
                    onGridStyleTap: { viewModel.gridStyle = viewModel.gridStyle.buttonNextGridSize() },
                    onGameTap: { game in
                        appCoordinator.path.append(GameListDestination.GameInfo(id: "\(game.appid)"))
                    }
                )
            }
            .simultaneousGesture(gridMagnificationGesture)
        }
    }
    
    var searchOverlayView: some View {
        Group {
            if viewModel.searching {
                SearchView(games: viewModel.searchedGames)
                    .padding(.top, 32)
                    .ignoresSafeArea(.container, edges: .bottom)
            }
        }
    }
    
    var bottomButtonStack: some View {
        BottomButtonStack(
            filterType: $viewModel.filterType,
            search: $viewModel.searchText,
            searching: $viewModel.searching
        )
        .padding()
        .ignoresSafeArea()
    }
}

// MARK: - Gestures
private extension ContentView {
    var gridMagnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged(handleMagnificationChanged)
            .onEnded(handleMagnificationEnded)
    }
    
    func handleMagnificationChanged(_ value: CGFloat) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.prepare()
        
        if value > 1.2 || value < 0.8 {
            impactFeedback.impactOccurred()
        }
    }
    
    func handleMagnificationEnded(_ value: CGFloat) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if value > 1.2 {
                viewModel.gridStyle = viewModel.gridStyle.addOne()
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            } else if value < 0.8 {
                viewModel.gridStyle = viewModel.gridStyle.decOne()
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }
}

// MARK: - Navigation
private extension ContentView {
    @ViewBuilder
    func navigationDestination(for destination: GameListDestination) -> some View {
        switch destination {
        case .GameInfo(id: let id):
            GameInfoView(viewModel: GameInfoViewModel(gameId: id))
        }
    }
}

// MARK: - Recent Games Section
struct RecentGamesSection: View {
    let status: APIStatus
    let games: [SteamGamesResumed]
    
    var body: some View {
        switch status {
        case .success:
            VStack(spacing: 0) {
                sectionHeader
                    .padding(.bottom)
                LastPlayedView(games: games)
            }
        case .failure:
            Text("Error")
        case .idle, .loading:
            ProgressView()
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text("Recent Activity")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 32)
                .padding(.horizontal, 8)
            Spacer()
        }
    }
}

// MARK: - Games Grid Section
struct GamesGridSection: View {
    let status: APIStatus
    let filterType: FilterTypes
    let gridStyle: GridSize
    let games: [SteamGamesResumed]
    let onGridStyleTap: () -> Void
    let onGameTap: (SteamGamesResumed) -> Void
    
    var body: some View {
        switch status {
        case .success:
            VStack(spacing: 0) {
                sectionHeader
                    .padding(.bottom)
                gamesGrid
            }
        case .failure:
            Text("Error")
        case .idle, .loading:
            ProgressView()
        }
    }
    
    private var sectionHeader: some View {
        HStack(alignment: .center) {
            Text(filterType.getName())
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                .padding(.horizontal, 8)
            Spacer()
            
            Button(action: onGridStyleTap) {
                Image(systemName: gridStyle.getGridImage())
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.top, 32)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    private var gamesGrid: some View {
        LazyVGrid(columns: gridColumns, alignment: .center) {
            ForEach(Array(games.enumerated()), id: \.offset) { _, game in
                GameView(game: game)
                    .onTapGesture {
                        onGameTap(game)
                    }
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var gridColumns: [GridItem] {
        (0..<gridStyle.rawValue).map { _ in GridItem(.flexible()) }
    }
}

#Preview {
    ContentView(viewModel: GamesListViewModel())
}

#Preview {
    ContentView(viewModel: GamesListViewModel())
}
