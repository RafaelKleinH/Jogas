//
//  GameSpoilerView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 17/08/25.
//

import SwiftUI

struct GameSpoilerView: View {
    
    @ObservedObject var viewModel: GameSpoilerViewModel
    
    var body: some View {
        ZStack {
            
            HStack {
                Spacer()
            }
            .appleIntelligenceEffect(isActive: $viewModel.spoilerLoading, cornerRadius: 46)
            .padding(2)
            .ignoresSafeArea(.container, edges: .vertical)
        
        
      
                getMainView()
 
        }
        .task {
            await viewModel.getGameSpoiler(gameId: viewModel.gameId)
        }
    }
    
    @ViewBuilder
    private func getMainView() -> some View {
        switch viewModel.spoilerState {
        case .success:
            ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                
                HStack {
                    Text("Lore visualizer")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                 
                    Spacer()
                }
                
                
                if let text = viewModel.spoilerText?.storyResume {
                    Text(AttributedString(text))
                        .padding()
                }
            }
            }
        case .failure:
            retryView
                .onTapGesture {
                    Task {
                        await viewModel.getGameSpoiler(gameId: viewModel.gameId)
                    }
                }
        case .idle, .loading:
            loadingView
        }
    }
    
    private var retryView: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            Image(systemName: "sparkles")
            Text("Tap to try again...")
            Spacer()
        }
    }
    
    
    private var loadingView: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            Image(systemName: "sparkles")
            Text("Generating Spoilers...")
            Spacer()
        }
    }
}



#Preview {
    GameSpoilerView(viewModel: .init(spoilerText: nil, gameId: ""))
}
