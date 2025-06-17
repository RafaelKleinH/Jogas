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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SteamGamePersistent.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
