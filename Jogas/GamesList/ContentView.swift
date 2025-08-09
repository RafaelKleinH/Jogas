//
//  ContentView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 07/01/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @ObservedObject
    private var viewModel: GamesListViewModel = .init()
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Query(sort: \SteamGamePersistent.rtimeLastPlayed, order: .reverse)
    var games: [SteamGamePersistent]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            VStack(alignment: .center) {
                
                if games.isEmpty {
                    ProgressView()
                        .onAppear {
                            viewModel.loadSteamGames(context: modelContext)
                        }
                        
                 
                    
                } else {
                    ScrollView {
                        
                        HStack {
                            Text("Recentes")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 64)
                                .padding(.horizontal, 8)
                            Spacer()
                            
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach((0...9), id: \.self) {
                                    GameView(game: games[$0])
                                        .frame(minHeight: 0, maxHeight: .infinity)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 4)
                                }
                            }
                            
                            
                        }
                        
                        ListFilterView()
                            .padding(.bottom, 16)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())],
                                  alignment: .center) {
                            ForEach(games) { game in
                                GameView(game: game)
                                    .padding(.bottom, 8)
                            }
                        }
                                  .padding(.horizontal, 4)
                    }
                }
            }
            
            HeaderView(viewModel: viewModel, modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SteamGamePersistent.self, inMemory: true)
}


//https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=A965E02B18CCD5E11925521BDD82C72B&steamid=76561198374492833&format=json&include_appinfo=true

