//
//  svenmodels.swift
//  SnapPop
//
//  Created by 김형준 on 8/13/24.
//


import Foundation
import FirebaseFirestore
import FirebaseStorage

class DailyModel {
    var snap = true
    var todoList: [String] = []
    
    init(snap: Bool = true, todoList: [String]) {
        self.snap = snap
        self.todoList = todoList
    }
}




struct Management1: Identifiable, Hashable, Codable {
    @DocumentID var id: String?
    let title: String
    let memo: String
    let color: String
    let startDate: Date
    let repeatCycle: Int
    let alertTime: Date
    let alertStatus: Bool
    let isDone: Bool
    
    init(title: String, memo: String, color: String, startDate: Date, repeatCycle: Int, alertTime: Date, alertStatus: Bool, isDone: Bool) {
        self.title = title
        self.memo = memo
        self.color = color
        self.startDate = startDate
        self.repeatCycle = repeatCycle
        self.alertTime = alertTime
        self.alertStatus = alertStatus
        self.isDone = isDone
    }
}


// MARK: - Management Extension
extension Management1 {
    static func generateSampleManagementItems() -> [Management1] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDate = dateFormatter.date(from: "2024-01-01") ?? Date()
        let alertTime = dateFormatter.date(from: "2024-12-31") ?? Date()
        
        return [
            Management1(
                title: "오메가3 챙겨먹기",
                memo: "임시데이터 입니다.",
                color: "#FF0000",
                startDate: startDate,
                repeatCycle: 7,
                alertTime: alertTime,
                alertStatus: true,
                isDone: true
            ),
            Management1(
                title: "립밤 바르기",
                memo: "임시데이터 입니다.",
                color: "#FF9500",
                startDate: startDate,
                repeatCycle: 0,
                alertTime: alertTime,
                alertStatus: false,
                isDone: false
            )
        ]
    }
}
