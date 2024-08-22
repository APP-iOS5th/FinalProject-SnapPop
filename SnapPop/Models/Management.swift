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
