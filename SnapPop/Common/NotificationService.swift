//
//  NotificationService.swift
//  SnapPop
//
//  Created by 이인호 on 8/23/24.
//

import Foundation
import UserNotifications

struct NotificationService {
    static let shared = NotificationService()
    
    func scheduleDailySnapNotification(hour: Int) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                var alertHour: Int = hour <= 20 ? hour : 10
                let content = UNMutableNotificationContent()
                content.title = "스냅 등록"
                content.sound = .default

                var dateComponents = DateComponents()
                dateComponents.hour = alertHour
                dateComponents.minute = 0
                
                if 5 <= alertHour && alertHour < 12 {
                    content.body = "오늘의 스냅을 등록하고 하루를 시작해보세요!"
                } else {
                    content.body = "오늘 스냅을 놓치신거같아요! 지금 바로 등록해보세요."
                }
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "dailySnapNotification", content: content, trigger: trigger)

                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func removeNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
