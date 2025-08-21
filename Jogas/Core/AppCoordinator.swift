//
//  AppCoordinator.swift
//  Jogas
//
//  Created by Rafael Hartmann on 20/08/25.
//

import SwiftUI

final class AppCoordinator: ObservableObject {
    @Published var path: NavigationPath

    init(path: NavigationPath) {
        self.path = path
    }
}
