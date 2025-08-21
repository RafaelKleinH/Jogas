//
//  GameSpoilerViewModel.swift
//  Jogas
//
//  Created by Rafael Hartmann on 20/08/25.
//

import SwiftUI
import Foundation

class GameSpoilerViewModel: ObservableObject {
    
    @Published var spoilerState: APIStatus
    @Published var spoilerText: SteamGameSpoiler?
    @Published var spoilerLoading: Bool
    
    let gameId: String
    
    init(spoilerText: String? = nil, gameId: String) {
        self.gameId = gameId
        self.spoilerText = spoilerText == nil ? nil : .init(storyResume: spoilerText ?? "")
        self.spoilerState = spoilerText == nil ? .idle : .success
        self.spoilerLoading = spoilerText == nil
    }
    
    @MainActor
    private func setupSpoilerState(with status: APIStatus) {
        spoilerState = status
        if status == .loading || status == .idle {
            spoilerLoading = true
        } else {
            spoilerLoading = false
        }
    }
    
    @MainActor
    private func setupSpoilerText(_ text: SteamGameSpoiler?) {
        spoilerText = text
    }
    
    func getGameSpoiler(gameId: String) async {
        guard spoilerText?.storyResume == nil else { return }
        await setupSpoilerState(with: .loading)
        
        do {
            let spoilerContent = try await loadSpoiler(gameId: gameId)
            await setupSpoilerText(spoilerContent)
            await setupSpoilerState(with: .success)
        } catch {
            await setupSpoilerState(with: .failure)
        }
    }
    
    
    private func loadSpoiler(gameId: String) async throws -> SteamGameSpoiler {
        guard let url = URL(string: NetworkCore.baseURL + "/api/games/\(gameId)/generate-story-resume") else {
            throw URLError(.badURL)
           
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        let spoilerContent = try JSONDecoder().decode(SteamGameSpoiler.self, from: data)
        return spoilerContent
    }
}
