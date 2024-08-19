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
