//
//  GameInfoViewModel.swift
//  Jogas
//
//  Created by Rafael Hartmann on 13/08/25.
//

import SwiftUI

enum APIStatus {
    case idle
    case loading
    case success
    case failure
}

class GameInfoViewModel: ObservableObject {
    @Published var gameInfo: SteamGame? = nil
    @Published var gameDetailStatus: APIStatus = .idle
    @Published var descStatus: APIStatus = .idle
    @Published var descLoading = false
    
    @Published var ratingStatus: APIStatus = .idle
    @Published var ratingLoading = false
    
    @Published public var firstSliderValue: Int = 0
    @Published public var lastSliderValue: Int = 0
    @Published public var firstDragValue: Int = 0
    @Published public var lastDragValue: Int = 0
    
    @Published var isPresenting: Bool = false
    
    let gameId: String
    
    public init(gameId: String) {
        self.gameId = gameId
    }
    
    private var hasLoadedInitialData = false
    
    @MainActor
    func updateGame(fetchedGame: SteamGame) {
        self.gameInfo = fetchedGame
    }
    
    @MainActor
    func updateGameDesc(desc: SteamGameDescription) {
        self.gameInfo?.description = desc.description
    }
    
    @MainActor
    func updateGameAverageRating(rating: Decimal) {
        self.gameInfo?.averageRating = rating
    }
    
    @MainActor
    func updateGameUserRating(rating: Decimal) {
        self.gameInfo?.userRating = rating
    }
    
    @MainActor
    func gameDetailStatus(status: APIStatus) {
        gameDetailStatus = status
    }
    
    @MainActor
    func descStatus(status: APIStatus) {
        descStatus = status
        switch status {
        case .idle, .success, .failure:
            descLoading = false
        case .loading:
            descLoading = true
        }
    }
    
    @MainActor
    func ratingStatus(status: APIStatus) {
        ratingStatus = status
        switch status {
        case .idle, .success, .failure:
            ratingLoading = false
        case .loading:
            ratingLoading = true
        }
    }
    
    func getGameDetail(gameId: String) async {
        await gameDetailStatus(status: .loading)
        
        do {
            let fetchedGame = try await loadHomeGames(gameId: gameId)
            await updateGame(fetchedGame: fetchedGame)
            await gameDetailStatus(status: .success)
        } catch {
            await gameDetailStatus(status: .failure)
        }
        
    }
    
    func getGameDescription(gameId: String) async {
        await descStatus(status: .loading)
        
        do {
            let fetchedGame = try await loadDescription(gameId: gameId)
            await updateGameDesc(desc: fetchedGame)
            await descStatus(status: .success)
        } catch {
            await descStatus(status: .failure)
        }
    }
    
    
    func getGameAverageRating(gameId: String) async {
        await ratingStatus(status: .loading)
        
        do {
            let fetchedGame = try await loadAverageRating(gameId: gameId)
            await updateGameAverageRating(rating: fetchedGame)
            await ratingStatus(status: .success)
        } catch {
            await ratingStatus(status: .failure)
        }
    }
    
    func postRating() async {
        
        guard let rating = Decimal(string: "\(firstSliderValue).\(lastSliderValue)") else { return }
        await updateGameUserRating(rating: rating)
        
        do {
            print("12")
            try await postRating(gameRating: rating, gameId: gameId)
        } catch {
            print(String(describing: error))
            return
        }
    }
    
    func calculatePlaytime(_ timeValue: Int) -> String {
            let timeMeasure = Measurement(value: Double(timeValue), unit: UnitDuration.minutes)
            let hours = timeMeasure.converted(to: .hours)
            if hours.value > 1 {
                let minutes = timeMeasure.value.truncatingRemainder(dividingBy: 60)
                return String(format: "%.f %@ %.f %@", hours.value, "h", minutes, "min")
            }
            return String(format: "%.f %@", timeMeasure.value, "min")
        }

    
    private func loadHomeGames(gameId: String) async throws -> SteamGame {
        let url = URL(string: NetworkCore.baseURL + "/api/games/\(gameId)")
        let request = URLRequest(url: url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let fetchedData = try JSONDecoder().decode(SteamGame.self, from: data)
        return fetchedData
    }

    private func loadDescription(gameId: String) async throws -> SteamGameDescription {
        let url = URL(string: NetworkCore.baseURL + "/api/games/\(gameId)/generate-description")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        let fetchedData = try JSONDecoder().decode(SteamGameDescription.self, from: data)
        return fetchedData
    }
    
    private func loadAverageRating(gameId: String) async throws -> Decimal {
        let url = URL(string: NetworkCore.baseURL + "/api/games/\(gameId)/generate-rating")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        let fetchedData = try JSONDecoder().decode(Decimal.self, from: data)
        return fetchedData
    }
    
    private func postRating(gameRating: Decimal, gameId: String) async throws -> Void {
        let url = URL(string: NetworkCore.baseURL + "/api/games/\(gameId)/user-rating")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print(gameRating)
        request.httpBody = try JSONEncoder().encode(SteamGameUserRate(userRating: gameRating))
        let (_, _) = try await URLSession.shared.data(for: request)
        return ()
    }
}

