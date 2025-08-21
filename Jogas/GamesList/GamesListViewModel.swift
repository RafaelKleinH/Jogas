//
//  GamesListViewModel.swift
//  Jogas
//
//  Created by Rafael Hartmann on 07/01/25.
//

import SwiftUI

class GamesListViewModel: ObservableObject {
    @Published var searching: Bool = false
   
    @Published var getGamesStatus: APIStatus = .idle
    @Published var getRecentGamesStatus: APIStatus = .idle
    
    @Published var needLoadingAnimation: Bool = false
    @Published var games: [SteamGamesResumed] = []
    @Published var recentGames: [SteamGamesResumed] = []
    @Published var filterType: FilterTypes = FilterTypes.most_played {
        didSet {
            Task {
                await getGames(filter: filterType.rawValue)
            }
        }
    }
    
    @Published var gridStyle: GridSize = .defaultSize
    
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
    
    private var hasLoadedInitialData = false
    
    func loadInitialDataIfNeeded(scrollRefresh: Bool) async {
        guard !hasLoadedInitialData || scrollRefresh else { return }
        hasLoadedInitialData = true
        
        print("TEST1")
        async let games: Void = getGames(filter: filterType.rawValue)
        async let recentGames: Void = getRecentGames()
        await games
        await recentGames
    }

    
    private func getGames(filter: String) async {
        await MainActor.run {
            games = []
            getGamesStatus = .loading
        }
        
        do {
            let fetchedGames = try await loadHomeGames(filterType: filter)
            await MainActor.run {
                self.games = fetchedGames
                self.searchedGames = games.count > 5 ? [games[0], games[1], games[2], games[3], games[4]] : []
                self.getGamesStatus = .success
            }
        } catch {
            print(error)
            await MainActor.run {
                self.getGamesStatus = .failure
                self.games = []
            }
        }
    }
    
    
    private func getRecentGames() async {
        await MainActor.run {
            self.getRecentGamesStatus = .loading
        }
        
        do {
            let fetchedGames = try await loadRecentGames()
            await MainActor.run {
                self.recentGames = fetchedGames
                self.getRecentGamesStatus = .success
            }
        } catch {
            print(error)
            await MainActor.run {
                self.getRecentGamesStatus = .failure
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

