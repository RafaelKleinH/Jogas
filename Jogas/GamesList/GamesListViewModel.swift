//
//  GamesListViewModel.swift
//  Jogas
//
//  Created by Rafael Hartmann on 07/01/25.
//

import Foundation
import SwiftData
import SwiftUI

class GamesListViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var needLoadingAnimation: Bool = false

    @MainActor
    func saveImage(image: Image, context: ModelContext, game: SteamGamePersistent) {
            let img = ImageRenderer(content: image).uiImage?.pngData()
            game.downloadedImg = img
            game.imgDownloaded = true
            try? context.save()
    }
    
    @MainActor
    func loadSteamGames(context: ModelContext) {
        Task {
            do {
                self.isLoading = true
                let games = try await loadGames()
                self.isLoading = false
                
               
                let userPesistent: UserDataPesistent = .init(gameCount: games.response.game_count)
                context.insert(userPesistent)
                
                var gamePersistent: [SteamGamePersistent] = []
                for game in games.response.games {
                    gamePersistent.append(.init(appid: game.appid,
                                                name: game.name,
                                                imgUrl: game.img_icon_url,
                                                playtime: game.playtime_forever,
                                                playtimeWindows: game.playtime_windows_forever,
                                                playtimeMac: game.playtime_mac_forever,
                                                playtimeLinux: game.playtime_linux_forever,
                                                playtimeDeck: game.playtime_deck_forever,
                                                rtimeLastPlayed: game.rtime_last_played,
                                                imgDownloaded: false))
                }
                userPesistent.games.append(contentsOf: gamePersistent)
                try? context.save()
                print(games)
            } catch {
                print(error)
            }
            self.isLoading = false
        }
    }
    
    func deleteSteamGames(context: ModelContext) {
        try? context.delete(model: UserDataPesistent.self)
    }
    
    private func loadGames() async throws -> SteamGamesDTO {
        let url = URL(string:"https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=A965E02B18CCD5E11925521BDD82C72B&steamid=76561198374492833&format=json&include_appinfo=true")
        let request = URLRequest(url: url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let fetchedData = try JSONDecoder().decode(SteamGamesDTO.self, from: data)
        return fetchedData
    }
}

