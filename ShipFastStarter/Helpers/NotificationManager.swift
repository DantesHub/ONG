//
//  NotificationManager.swift
//  ONG
//
//  Created by Dante Kim on 9/8/24.
//

import Foundation
import UserNotifications

struct NotificationManager {

    // for when the countdown ends
    static func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}