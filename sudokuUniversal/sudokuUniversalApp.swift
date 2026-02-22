//
//  sudokuUniversalApp.swift
//  sudokuUniversal
//
//  Created by kam keung pun on 21/2/2026.
//

import SwiftUI

@main
struct sudokuUniversalApp: App {
    let persistenceController = PersistenceController.shared
    @State private var gameStateManager = GameStateManager()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(gameStateManager)
        }
    }
}
