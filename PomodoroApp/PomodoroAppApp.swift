//
//  PomodoroAppApp.swift
//  PomodoroApp
//
//  Created by Evrim Tuncel on 2.05.2023.
//

import SwiftUI

@main
struct PomodoroAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
