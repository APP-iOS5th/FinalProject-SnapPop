//
//   ManagementModel.swift
//  SnapPop
//
//  Created by 장예진 on 8/9/24.
//

// MARK: 기존에 설정된 데이터 모델에 맞게 수정

import Foundation
import UIKit

struct Management: Codable {
    let id: String
    let categoryId: String
    var title: String
    var color: String
    var memo: String
    var status: Bool
    var createdAt: Date
    var repeatCycle: Int
    var endDate: Date?
    var hasTimeAlert: Bool
    var hasNotification: Bool
    
    init(id: String = UUID().uuidString,
         categoryId: String,
         title: String,
         color: String,
         memo: String,
         status: Bool = true,
         createdAt: Date = Date(),
         repeatCycle: Int,
         endDate: Date? = nil,
         hasTimeAlert: Bool = false,
         hasNotification: Bool = false) {
        self.id = id
        self.categoryId = categoryId
        self.title = title
        self.color = color
        self.memo = memo
        self.status = status
        self.createdAt = createdAt
        self.repeatCycle = repeatCycle
        self.endDate = endDate
        self.hasTimeAlert = hasTimeAlert
        self.hasNotification = hasNotification
    }
}
