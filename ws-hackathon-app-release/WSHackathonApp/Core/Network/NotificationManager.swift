//
//  NotificationManager.swift
//  WSHackathonApp
//
//  Created by Antigravity on 17/05/26.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    override private init() {
        super.init()
        // Register the delegate to listen for active foreground notifications
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// Requests native user notification permission on launch
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("🔔 Notification permission granted.")
            } else if let error = error {
                print("❌ Notification permission denied: \(error.localizedDescription)")
            }
        }
    }
    
    /// Schedules a local push notification to fire after a specified delay
    func scheduleNotification(title: String, body: String, delay: TimeInterval = 1.0) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(0.1, delay), repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule local notification: \(error.localizedDescription)")
            } else {
                print("🔔 Scheduled notification: \(title)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // This allows slide-down push notification banners to appear while the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner and play system notification sound
        completionHandler([.banner, .list, .sound])
    }
}
