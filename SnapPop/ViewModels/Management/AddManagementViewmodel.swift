//
//  AddManagementViewmodel.swift
//  SnapPop
//
//  Created by 장예진 on 8/9/24.
//

import UIKit

class AddManagementViewModel {
    private var management: Management
    
    let repeatOptions = ["매일", "매주", "매달", "안함"] 
    
    init(categoryId: String) {
        self.management = Management(
            categoryId: categoryId,
            title: "",
            color: "#000000",
            memo: "",
            repeatCycle: 0
        )
    }
    
    func updateTitle(_ title: String) {
        management.title = title
    }
    
    func updateColor(_ color: UIColor) {
        management.color = color.toHexString()
    }
    
    func updateMemo(_ memo: String) {
        management.memo = memo
    }
    
    func updateDate(_ date: Date) {
        management.createdAt = date
    }
    
    func updateRepeatCycle(_ repeatCycle: Int) {
        management.repeatCycle = repeatCycle
    }
    
    func updateEndDate(_ endDate: Date?) {
        management.endDate = endDate
    }
    
    func updateHasTimeAlert(_ hasTimeAlert: Bool) {
        // TODO: 시간 알림을 켜고 끄는거 업데이트
    }
    
    func updateTime(_ time: Date) {
        // TODO: 시간 업데이트 구현
    }
    
    func updateHasNotification(_ hasNotification: Bool) {
        // TODO: 알림 상태를 업데이트
    }
    
    func save(completion: @escaping (Result<Void, Error>) -> Void) {
        // TODO: 실제 저장 로직
        completion(.success(()))
    }
}

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format: "#%06x", rgb)
    }
}
