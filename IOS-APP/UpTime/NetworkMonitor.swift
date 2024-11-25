import Foundation
import UserNotifications
import BackgroundTasks
import SwiftUI

class NetworkMonitor: ObservableObject {
    private var failedPingCounts: [String: Int] = [:]
    
    private let defaults = UserDefaults.standard
    
    @Published private(set) var maxFailedPings: Int = 5
    @Published private(set) var notificationsEnabled: Bool = true
    @Published private(set) var backgroundRefreshInterval: Int = 15 // in Minuten
    
    // Hinzufügung der refreshIntervals
    let refreshIntervals = [
        5: "5 Minuten",
        10: "10 Minuten",
        15: "15 Minuten",
        30: "30 Minuten",
        60: "1 Stunde"
    ]
    
    init() {
        if let savedMaxPings = defaults.object(forKey: "maxFailedPings") as? Int {
            maxFailedPings = savedMaxPings
        }
        
        if let savedNotificationsEnabled = defaults.object(forKey: "notificationsEnabled") as? Bool {
            notificationsEnabled = savedNotificationsEnabled
        }
        
        if let savedRefreshInterval = defaults.object(forKey: "backgroundRefreshInterval") as? Int {
            backgroundRefreshInterval = savedRefreshInterval
        }
        
        registerBackgroundTask()
    }
    
    func setMaxFailedPings(_ value: Int) {
        maxFailedPings = value
        defaults.set(value, forKey: "maxFailedPings")
    }
    
    func setNotificationsEnabled(_ value: Bool) {
        notificationsEnabled = value
        defaults.set(value, forKey: "notificationsEnabled")
    }
    
    func setBackgroundRefreshInterval(_ minutes: Int) {
        backgroundRefreshInterval = minutes
        defaults.set(minutes, forKey: "backgroundRefreshInterval")
        // Neu planen mit dem aktualisierten Intervall
        scheduleBackgroundTask()
    }
    
    func checkService(_ service: Service) {
        let serviceId = service.id.uuidString
        
        if !service.isOnline {
            failedPingCounts[serviceId, default: 0] += 1
            
            if notificationsEnabled && failedPingCounts[serviceId] == maxFailedPings {
                sendNotification(for: service)
            }
        } else {
            failedPingCounts[serviceId] = 0
        }
    }
    
    private func sendNotification(for service: Service) {
        let content = UNMutableNotificationContent()
        content.title = "Service Offline"
        content.body = "\(service.name) ist seit \(maxFailedPings) Pings nicht erreichbar"
        content.sound = .default
        
        content.interruptionLevel = .timeSensitive
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "de.leander-kretschmer.UpTime.refresh",
            using: nil
        ) { task in
            self.handleBackgroundTask(task as! BGAppRefreshTask)
        }
    }
    
    private func handleBackgroundTask(_ task: BGAppRefreshTask) {
        scheduleBackgroundTask()
        
        task.expirationHandler = {
            // Handle task expiration
        }
        
        // Your service checking logic here
        // ...
        
        task.setTaskCompleted(success: true)
    }
    
    func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "de.leander-kretschmer.UpTime.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(backgroundRefreshInterval * 60))
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}

extension UserDefaults {
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
} 