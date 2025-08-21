//
//  Item.swift
//  Jogas
//
//  Created by Rafael Hartmann on 07/01/25.
//

import Foundation
import SwiftData
import SwiftUI

struct SteamGame: Codable, Equatable {
    let appid: Int
    let name: String
    let img_icon_url: String
    let playtime_forever: Int
    let playtime_windows_forever: Int
    let playtime_mac_forever: Int
    let playtime_linux_forever: Int
    let playtime_deck_forever: Int
    let rtime_last_played: Int
    var description: String?
    let storyResume: String?
    var averageRating: Decimal?
    let userRating: Decimal?
}

struct SteamGameDescription: Codable, Equatable {
    var description: String
}

struct SteamGameSpoiler: Codable, Equatable {
    var storyResume: String
}


struct SteamGamesResumed: Codable, Equatable {
    let appid: Int
    let name: String
    var img_icon_url: String?
}

enum FilterTypes: String {
    case alphabetical
    case most_played
    case least_played
    case recent_played
    
    func getName() -> String {
        switch self {
        case .alphabetical:
            "Alphabetically"
        case .most_played:
            "Most played"
        case .least_played:
            "Least played"
        case .recent_played:
            "Recent games"
        }
    }
    
    func getImage() -> String {
        switch self {
        case .alphabetical:
            "textformat.characters"
        case .most_played:
            "hourglass.tophalf.filled"
        case .least_played:
            "hourglass.bottomhalf.filled"
        case .recent_played:
            "gamecontroller.fill"
        }
    }
}

enum GridSize: Int {
    case lib = 6
    case small = 4
    case defaultSize = 3
    case large = 2
    case largest = 1
    
    func addOne() -> GridSize {
        switch self {
        case .lib:
            return .small
        case .small:
            return .defaultSize
        case .defaultSize:
            return .large
        case .large:
            return .largest
        case .largest:
            return .largest
        }
    }
    
    func decOne() -> GridSize {
        switch self {
        case .largest:
            return .large
        case .large:
            return .defaultSize
        case .defaultSize:
            return .small
        case .small:
            return .lib
        case .lib:
            return .lib
        }
    }
    
    func buttonNextGridSize() -> GridSize {
        switch self {
        case .largest:
            return .large
        case .large:
            return .defaultSize
        case .defaultSize:
            return .small
        case .small:
            return .lib
        case .lib:
            return .largest
        }
    }
    
    func getGridImage() -> String {
        switch self {
        case .lib:
            "book"
        case .small:
            "book.pages"
        case .defaultSize:
            "square.grid.3x3"
        case .large:
            "square.grid.2x2"
        case .largest:
            "square"
        }
    }
}

enum GameInfoDestination: Hashable {
    case GameSpoiler(text: String?)
    case GameRating
}

enum GameListDestination: Hashable {
    case GameInfo(id: String)
}
