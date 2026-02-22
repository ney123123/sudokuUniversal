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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
