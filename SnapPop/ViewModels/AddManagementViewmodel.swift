//
//  AddManagementViewmodel.swift
//  SnapPop
//
//  Created by 장예진 on 8/9/24.
//

import UIKit

class AddManagementViewModel {
    private var management: Management?
    var onUpdate: (() -> Void)?
    
    init() {
        self.management = Management(id: UUID(),
                                     title: "",
                                     color: .blue,
                                     memo: "",
                                     date: Date(),
                                     repeatType: .none,
                                     hasTimeAlert: false,
                                     time: nil,
                                     hasNotification: false,
                                     details: [])
    }
    
    func updateTitle(_ title: String) {
        management?.title = title
        onUpdate?()
    }
    
    func updateColor(_ color: UIColor) {
        management?.color = color
        onUpdate?()
    }
    
    func updateMemo(_ memo: String) {
        management?.memo = memo
        onUpdate?()
    }
    
    func updateDate(_ date: Date) {
        management?.date = date
        onUpdate?()
    }
    
    func updateRepeatType(_ repeatType: RepeatType) {
        management?.repeatType = repeatType
        onUpdate?()
    }
    
    func updateHasTimeAlert(_ hasTimeAlert: Bool) {
        management?.hasTimeAlert = hasTimeAlert
        onUpdate?()
    }
    
    func updateTime(_ time: Date?) {
        management?.time = time
        onUpdate?()
    }
    
    func updateHasNotification(_ hasNotification: Bool) {
        management?.hasNotification = hasNotification
        onUpdate?()
    }
    
    func addDetail(_ detail: ManagementDetail) {
        management?.details.append(detail)
        onUpdate?()
    }
    
    func save(completion: @escaping (Result<Void, Error>) -> Void) {
        guard management != nil else {
            completion(.failure(NSError(domain: "AddManagementViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No management data to save"])))
            return
        }
        

        // 저장이 성공했다고 가정합니다.
        completion(.success(()))
    }
}
