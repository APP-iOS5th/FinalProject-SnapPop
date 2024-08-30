//
//  Notification+Extensions.swift
//  SnapPop
//
//  Created by 정종원 on 8/30/24.
//

import Foundation

extension Notification.Name {
    static let newNotificationReceived = Notification.Name("newNotificationReceived")
    static let newRecommendNotificationReceived = Notification.Name("newsavedRecommendNotificationsNotificationReceived")
    static let categoryDidChange = Notification.Name("categoryDidChange")
}
