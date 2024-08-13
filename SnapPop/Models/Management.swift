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
    let status: Bool
    
    init(title: String, memo: String, color: String, startDate: Date, repeatCycle: Int, status: Bool) {
        self.title = title
        self.memo = memo
        self.color = color
        self.startDate = startDate
        self.repeatCycle = repeatCycle
        self.status = status
    }
}
