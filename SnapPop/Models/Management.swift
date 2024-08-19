//
//  Management.swift
//  SnapPop
//
//  Created by 이인호 on 8/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

struct Management: Identifiable, Hashable, Codable {
    @DocumentID var id: String?
    let title: String
    let memo: String
    let color: String
    let startDate: Date
    let repeatCycle: Int
    let alertTime: Date
    let alertStatus: Bool
    
    init(title: String, memo: String, color: String, startDate: Date, repeatCycle: Int, alertTime: Date, alertStatus: Bool) {
        self.title = title
        self.memo = memo
        self.color = color
        self.startDate = startDate
        self.repeatCycle = repeatCycle
        self.alertTime = alertTime
        self.alertStatus = alertStatus
    }
}


// MARK: - Management Extension
extension Management {
    static func generateSampleManagementItems() -> [Management] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDate = dateFormatter.date(from: "2024-01-01") ?? Date()
        let alertTime = dateFormatter.date(from: "2024-12-31") ?? Date()
        
        return [
            Management(
                title: "오메가3 챙겨먹기",
                memo: "임시데이터 입니다.",
                color: "#FF0000",
                startDate: startDate,
                repeatCycle: 7,
                alertTime: alertTime,
                alertStatus: true
            ),
            Management(
                title: "립밤 바르기",
                memo: "임시데이터 입니다.",
                color: "#FF9500",
                startDate: startDate,
                repeatCycle: 0,
                alertTime: alertTime,
                alertStatus: false
            )
        ]
    }
}