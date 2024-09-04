//
//  NotificationSettingViewModel.swift
//  SnapPop
//
//  Created by 정종원 on 8/29/24.
//

import Foundation
protocol NotificationSettingViewModelProtocol {
    var categories: [Category] { get set }
    
    func loadCategories(completion: @escaping () -> Void)
    func updateCategory(categoryId: String, category: Category, completion: @escaping () -> Void)
    func removeAllNotifications(for categoryId: String)
    func registerAllNotifications(for categoryId: String)
}

class NotificationSettingViewModel: NotificationSettingViewModelProtocol{
    // MARK: - Properties
    var categories: [Category] = [
    ]
    private let categoryService = CategoryService()
    private let managementService = ManagementService()
    
    // MARK: - Initializer
    init() {
        loadCategories {
            // ViewController에서 UI를 업데이트
        }
    }
    // MARK: - Methods
    func loadCategories(completion: @escaping () -> Void) {
        categoryService.loadCategories { result in
            switch result {
            case .success(let categories):
                if categories.isEmpty {
                    // 파이어베이스에 카테고리가 없는 경우
                    print("파이어베이스에 카테고리가 없음")
                } else {
                    self.categories = categories
                    completion()
                }
            case .failure(let error):
                print("Failed to load categories: \(error.localizedDescription)")
            }
        }
    }
    
    func updateCategory(categoryId: String, category: Category, completion: @escaping () -> Void) {
        categoryService.updateCategory(categoryId: categoryId, updatedCategory: category) { result in
            switch result {
            case .success:
                completion()
            case .failure(let error):
                print("Failed to save error: \(error.localizedDescription)")
                completion()
            }
        }
    }
    
    /// 모든 알림 제거
    func removeAllNotifications(for categoryId: String) {
        managementService.loadManagements(categoryId: categoryId) { result in
            switch result {
            case .success(let managements):
                let identifiers = managements.filter { $0.alertStatus }.flatMap {
                    let initialNotification = "initialNotification-\(categoryId)-\($0.id ?? "")"
                    let repeatingNotification = "repeatingNotification-\(categoryId)-\($0.id ?? "")"
                    return [initialNotification, repeatingNotification]
                }
                NotificationManager.shared.removeNotification(identifiers: identifiers)
            case .failure(let error):
                print("Failed to load managements: \(error.localizedDescription)")
            }
        }
    }
    
    /// 모든 알림 등록
    func registerAllNotifications(for categoryId: String) {
        managementService.loadManagements(categoryId: categoryId) { result in
            switch result {
            case .success(let managements):
                managements.forEach { management in
                    if management.alertStatus {
                        if management.repeatCycle == 0 {
                            // 반복이 없는 알림 추가
                            NotificationManager.shared.initialNotification(categoryId: categoryId,
                                                                           managementId: management.id ?? "",
                                                                           startDate: management.startDate,
                                                                           alertTime: management.alertTime,
                                                                           repeatCycle: management.repeatCycle,
                                                                           body: management.title)
                        } else {
                            // 반복이 있는 알림 추가
                            if self.isSpecificDateInPast(startDate: management.startDate, alertTime: management.alertTime) {
                                // 과거 날짜에 대한 반복 알림 추가
                                NotificationManager.shared.repeatingNotification(categoryId: categoryId,
                                                                                 managementId: management.id ?? "",
                                                                                 startDate: management.startDate,
                                                                                 alertTime: management.alertTime,
                                                                                 repeatCycle: management.repeatCycle,
                                                                                 body: management.title)
                            } else {
                                // 반복 알림을 트리거할 초기 알림 추가
                                NotificationManager.shared.initialNotification(categoryId: categoryId,
                                                                               managementId: management.id ?? "",
                                                                               startDate: management.startDate,
                                                                               alertTime: management.alertTime,
                                                                               repeatCycle: management.repeatCycle,
                                                                               body: management.title)
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Failed to load managements: \(error.localizedDescription)")
            }
        }
    }
    
    // 시작 날짜+시간이 현재보다 과거인지 아닌지를 확인하는 함수
    func isSpecificDateInPast(startDate: Date, alertTime: Date) -> Bool {
        let calendar = Calendar.current
        
        // startDate에서 year, month, day를 추출
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        
        // alertTime에서 hour, minute를 추출
        dateComponents.hour = calendar.component(.hour, from: alertTime)
        dateComponents.minute = calendar.component(.minute, from: alertTime)
        
        if let specificDate = calendar.date(from: dateComponents) {
            return specificDate < Date()
        } else {
            return false
        }
    }
}
