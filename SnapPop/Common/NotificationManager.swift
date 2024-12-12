//
//  NotificationService.swift
//  SnapPop
//
//  Created by 이인호 on 8/23/24.
//

import Foundation
import UserNotifications

struct NotificationManager {
    static let shared = NotificationManager()
    let center = UNUserNotificationCenter.current()
    
    // 스냅 알림
    func scheduleDailySnapNotification(hour: Int) {
        var alertHour: Int = hour <= 20 ? hour : 10 // 21시 이후부터는 밤이므로 해당 시간에 알림을 보내지 않고 10시로 시간을 고정해 알림을 보냄
        let content = UNMutableNotificationContent()
        content.title = "SnapPop"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = alertHour
        dateComponents.minute = 0
        
        // 오전, 오후에 보내는 알림 메세지가 각각 다르게 처리
        if 5 <= alertHour && alertHour < 12 {
            content.body = "오늘의 스냅을 등록하고 하루를 시작해보세요!"
        } else {
            content.body = "오늘 스냅을 놓치신거같아요! 지금 바로 등록해보세요."
        }
        
//        let alertTime = Calendar.current.date(from: dateComponents) ?? Date() // 날짜를 못가져옴(0001-01-01로 가져옴). SceneDelegate에서 현재 날짜(Date())로 값 넣어주도록 변경
        content.userInfo = ["body": content.body]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailySnapNotification", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // 초기 알림 (반복되지 않는 알림이나, 반복되는 알림을 등록하기 위한 트리거로 사용함)
    func initialNotification(categoryId: String, managementId: String, startDate: Date, alertTime: Date, repeatCycle: Int, body: String) {
        let content = UNMutableNotificationContent()
        content.title = "SnapPop"
        content.body = body
        content.sound = .default
        
        // 반복 알림을 등록하는 시점에 사용하기 위해 초기 알림에 정보를 실어서 보내기 위한 userInfo
        content.userInfo = ["categoryId": categoryId,
                            "managementId": managementId,
                            "startDate": startDate,
                            "alertTime": alertTime,
                            "repeatCycle": repeatCycle,
                            "body": body]
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
        dateComponents.hour = Calendar.current.component(.hour, from: alertTime)
        dateComponents.minute = Calendar.current.component(.minute, from: alertTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "initialNotification-\(categoryId)-\(managementId)",
                                            content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // 반복 알림 (매일 반복, 매주 반복)
    func repeatingNotification(categoryId: String, managementId: String, startDate: Date, alertTime: Date, repeatCycle: Int, body: String) {
        let content = UNMutableNotificationContent()
        content.title = "SnapPop"
        content.body = body
        content.sound = .default
        
        var dateComponents = DateComponents()
        
        if repeatCycle == 1 {
            dateComponents.hour = Calendar.current.component(.hour, from: alertTime)
            dateComponents.minute = Calendar.current.component(.minute, from: alertTime)
        } else if repeatCycle == 7 {
            dateComponents.weekday = Calendar.current.component(.weekday, from: startDate) // 매주 반복 시 시작 날짜의 요일을 받아와 해당 요일마다 반복하도록 함
            dateComponents.hour = Calendar.current.component(.hour, from: alertTime)
            dateComponents.minute = Calendar.current.component(.minute, from: alertTime)
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "repeatingNotification-\(categoryId)-\(managementId)",
                                            content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // 알림 삭제
    func removeNotification(identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // 알림 전체삭제
    func removeAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}
