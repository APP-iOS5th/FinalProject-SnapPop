//
//   ManagementModel.swift
//  SnapPop
//
//  Created by 장예진 on 8/9/24.
//

import UIKit

struct Management {
    let id: UUID
    var title: String
    var color: UIColor
    var memo: String
    var date: Date
    var repeatType: RepeatType
    var hasTimeAlert: Bool
    var time: Date?
    var hasNotification: Bool
    var details: [ManagementDetail]
}

struct ManagementDetail {
    let id: UUID
    var title: String
    var description: String
    var cost: Double?
    var purchasePrice: Double?
    var estimatedUses: Int?
}

enum RepeatType: String, CaseIterable {
    case none = "안함"
    case daily = "매일"
    case weekly = "매주"
    case monthly = "매달"
}
