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
        VStack(alignment: .leading) {
            
            HeaderView()
            if games.isEmpty {
                VStack() {
                    
                    Button {
                        viewModel.loadSteamGames(context: modelContext)
                    } label: {
                        Image(systemName: "arrow.down.circle")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 168)
                            .padding(.top, 124)
                            .tint(.primary)
                            .symbolRenderingMode(.hierarchical)
                            .symbolEffectsRemoved(!viewModel.isLoading)
                            .symbolEffect(.pulse.byLayer, options: .repeat(.continuous), value: viewModel.needLoadingAnimation)
                            .onChange(of: viewModel.isLoading, { viewModel.needLoadingAnimation.toggle() })
                        
                    }
                    
                    Text("Nenhum jogo encontrado.")
                        .font(.title)
                        .padding(.top, 32)
                        .padding(.horizontal, 24)
                    
                    Text("Se quiser pode baixar a sua biblioteca da Steam clicando na imagem acima.")
                        .font(.subheadline)
                        .padding(.horizontal, 24)
                    
                    Spacer(minLength: 24)
                    
                }
                
            } else {
                ScrollView {
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
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())],
                              alignment: .center) {
                        ForEach(games) { game in
                            GameView(game: game)
                                .padding(.bottom, 8)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SteamGamePersistent.self, inMemory: true)
}


//https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=A965E02B18CCD5E11925521BDD82C72B&steamid=76561198374492833&format=json&include_appinfo=true
