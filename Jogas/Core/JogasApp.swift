//
//  JogasApp.swift
//  Jogas
//
//  Created by Rafael Hartmann on 07/01/25.
//

import SwiftUI
import SwiftData

@main
struct JogasApp: App {
    
    @StateObject private var appCoordinator = AppCoordinator(path: NavigationPath())
    @StateObject private var gamesListViewModel = GamesListViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appCoordinator.path) {
                ContentView(viewModel: gamesListViewModel)
            }
            .environmentObject(appCoordinator)
        }
    }
}
