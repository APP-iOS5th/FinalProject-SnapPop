//
//  Management.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/19/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

// -MARK: 값 업데이트 용이를 위해 선언 변경

struct Management: Identifiable, Hashable, Codable {
    @DocumentID var id: String?
    var title: String
    var memo: String
    var color: String
    var startDate: Date
    var repeatCycle: Int
    var alertTime: Date
    var alertStatus: Bool
    var completions: [String: Int]
    
    init(title: String, memo: String, color: String, startDate: Date, repeatCycle: Int, alertTime: Date, alertStatus: Bool, completions: [String: Int]) {
        self.title = title
        self.memo = memo
        self.color = color
        self.startDate = startDate
        self.repeatCycle = repeatCycle
        self.alertTime = alertTime
        self.alertStatus = alertStatus
        self.completions = completions
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
                alertStatus: true, completions: ["2024-08-23" : 1]
            ),
            Management(
                title: "립밤 바르기",
                memo: "임시데이터 입니다.",
                color: "#FF9500",
                startDate: startDate,
                repeatCycle: 0,
                alertTime: alertTime,
                alertStatus: false, completions: ["2024-08-23" : 0]
            )
        ]
    }
}
