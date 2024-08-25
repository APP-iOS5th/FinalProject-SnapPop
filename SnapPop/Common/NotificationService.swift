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
    
    func initialNotification(managementId: String, startDate: Date, alertTime: Date, repeatCycle: Int, body: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "관리 알림"
                content.body = body
                content.sound = .default
                
                content.userInfo = ["managementId": managementId, "startDate": startDate, "alertTime": alertTime, "repeatCycle": repeatCycle, "body": body]
                
                var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
                dateComponents.hour = Calendar.current.component(.hour, from: alertTime)
                dateComponents.minute = Calendar.current.component(.minute, from: alertTime)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: "initialNotification-\(managementId)", content: content, trigger: trigger)
                
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func repeatingNotification(managementId: String, startDate: Date, alertTime: Date, repeatCycle: Int, body: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "관리 알림"
                content.body = body
                content.sound = .default
                
                var dateComponents = DateComponents()
                
                if repeatCycle == 1 {
                    dateComponents.hour = Calendar.current.component(.hour, from: alertTime)
                    dateComponents.minute = Calendar.current.component(.minute, from: alertTime)
                } else if repeatCycle == 7 {
                    dateComponents.weekday = Calendar.current.component(.weekday, from: startDate)
                    dateComponents.hour = Calendar.current.component(.hour, from: alertTime)
                    dateComponents.minute = Calendar.current.component(.minute, from: alertTime)
                }
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "repeatingNotification-\(managementId)", content: content, trigger: trigger)
                
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
