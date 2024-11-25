//
//  UpTimeApp.swift
//  UpTime
//
//  Created by Leander Kretschmer on 25.11.24.
//

import SwiftUI
import BackgroundTasks

@main
struct UpTimeApp: App {
    @StateObject private var networkMonitor = NetworkMonitor()
    
    init() {
        registerBackgroundTasks()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkMonitor)
        }
    }
    
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "de.leander-kretschmer.UpTime.refresh",
            using: nil
        ) { task in
            // Handle background task
            task.setTaskCompleted(success: true)
        }
    }
}
