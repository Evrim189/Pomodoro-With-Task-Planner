//
//  PomodoroAppApp.swift
//  PomodoroApp
//
//  Created by Evrim Tuncel on 2.05.2023.
//

import SwiftUI

@main
struct PomodoroApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var currentSpot:Int = 0
    @State var showSpotlight = false
    
    var body: some Scene {
        
        WindowGroup {
            NavigationView{
                HomePage(showSpotlight: showSpotlight )
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            .onAppear{
                if !UserDefaults.standard.bool(forKey: "isShownSpotlight"){
                    showSpotlight = true
                    UserDefaults.standard.set(true, forKey: "isShownSpotlight")
                }
            }
            .addSpotlightOverlay(show: $showSpotlight, currentSpot: $currentSpot)
        }
    }
}
