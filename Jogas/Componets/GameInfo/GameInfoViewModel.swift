//
//  GameInfoViewModel.swift
//  Jogas
//
//  Created by Rafael Hartmann on 13/08/25.
//

import SwiftUI

class GameInfoViewModel: ObservableObject {
    @Published var gameInfo: SteamGame? = nil
    @Published var isLoading: Bool = false
    
    let gameId: String
    
    public init(gameId: String) {
        self.gameId = gameId
    }
    
    @MainActor
    func updateGames(fetchedGame: SteamGame) {
        self.gameInfo = fetchedGame
    }
    
    @MainActor
    func isLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    func getGameDetail(gameId: String) async {
        await isLoading(true)
        
        do {
            let fetchedGame = try await loadHomeGames(gameId: gameId)
            await updateGames(fetchedGame: fetchedGame)
            await isLoading(false)
        } catch {

        }
        await isLoading(false)
    }
    
    private func loadHomeGames(gameId: String) async throws -> SteamGame {
        let url = URL(string: NetworkCore.baseURL + "/api/games/\(gameId)")
        let request = URLRequest(url: url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let fetchedData = try JSONDecoder().decode(SteamGame.self, from: data)
        return fetchedData
    }
}
