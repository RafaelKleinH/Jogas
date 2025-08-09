//
//  HeaderView.swift
//  HeaderView
//
//  Created by Rafael Hartmann on 17/06/25.
//

import SwiftUI
import SwiftData

struct HeaderView: View {
    @ObservedObject var viewModel: GamesListViewModel
    var modelContext: ModelContext

    var body: some View {
        HStack {
            // TODO: - Crash
            
            Spacer()
            Button(action: {
                viewModel.deleteSteamGames(context: modelContext)
            }) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.accentColor)
            }
            .headerButtonStyle()
            
 
        }
        .padding()
    }
}

#Preview {
    HeaderView(viewModel: GamesListViewModel(), modelContext: try! ModelContainer(for: SteamGamePersistent.self).mainContext)
}
