//
//  NotificationSettingViewModel.swift
//  SnapPop
//
//  Created by 정종원 on 8/29/24.
//

import Foundation
protocol NotificationSettingViewModelProtocol {
    var categories: [Category] { get set }
}

class NotificationSettingViewModel: NotificationSettingViewModelProtocol{
    // MARK: - Properties
//    var categories: [Category] = []
    var categories: [Category] = [
        Category(userId: "user1", title: "탈모 관리", alertStatus: true),
        Category(userId: "user1", title: "팔자주름 관리", alertStatus: false),
        Category(userId: "user1", title: "바디 체크", alertStatus: false)
    ]
    
    //MARK: - Initializer
    init() {
        // 파이어 베이스 데이터 가져와서 categories 넣어주기;
    }
    //MARK: - Methods
}
