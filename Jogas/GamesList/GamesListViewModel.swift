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
    @Published var searching: Bool = false
    @Published var isLoading: Bool = false
    @Published var needLoadingAnimation: Bool = false
    @Published var games: [SteamGamesResumed] = []
    @Published var recentGames: [SteamGamesResumed] = []
    @Published var filterType: FilterTypes = FilterTypes.recent_played {
        didSet {
            Task {
                await getGames(filter: filterType.rawValue)
            }
        }
    }
    
    @Published var searchedGames: [SteamGamesResumed] = []
    @Published var searchText: String = "" {
        didSet {
            if searchText.count > 2 {
                Task {
                    await getSearchGames(name: searchText)
                }
            }
        }
    }

    
    func getGames(filter: String) async {
        await MainActor.run {
            games = []
            self.isLoading = true
        }
        
        do {
            let fetchedGames = try await loadHomeGames(filterType: filter)
            await MainActor.run {
                self.games = fetchedGames
                self.searchedGames = games
                self.isLoading = false
            }
        } catch {
            print(error)
            await MainActor.run {
                self.isLoading = false
                self.games = []
            }
        }
    }
    
    
    func getRecentGames() async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let fetchedGames = try await loadRecentGames()
            await MainActor.run {
                self.recentGames = fetchedGames
                self.isLoading = false
            }
        } catch {
            print(error)
            await MainActor.run {
                self.isLoading = false
                self.recentGames = []
            }
        }
    }
    
    func getSearchGames(name: String) async {
        
        do {
            let fetchedGames = try await searchGames(name: name)
            await MainActor.run {
                print(fetchedGames)
                self.searchedGames = fetchedGames
            }
        } catch {
            print(error)
            await MainActor.run {
                self.searchedGames = []
            }
        }
    }
    
    
    private func loadHomeGames(filterType: String) async throws -> [SteamGamesResumed] {
        let url = URL(string: NetworkCore.baseURL + "/api/games?filter=\(filterType)")
        let request = URLRequest(url: url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let fetchedData = try JSONDecoder().decode([SteamGamesResumed].self, from: data)
        return fetchedData
    }
    
    private func loadRecentGames() async throws -> [SteamGamesResumed] {
        let url = URL(string: NetworkCore.baseURL + "/api/games/recent")
        let request = URLRequest(url: url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let fetchedData = try JSONDecoder().decode([SteamGamesResumed].self, from: data)
        return fetchedData
    }
    
    private func searchGames(name: String) async throws -> [SteamGamesResumed] {
        let url = URL(string: NetworkCore.baseURL + "/api/games/search?name=\(name)")
        let request = URLRequest(url: url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let fetchedData = try JSONDecoder().decode([SteamGamesResumed].self, from: data)
        return fetchedData
    }
}

