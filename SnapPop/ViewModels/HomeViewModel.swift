//
//  File.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/8/24.
//

import Foundation
import UIKit
import Photos

//카테고리 임시데이터
struct Category {
    let id: String
    let userId: String
    let name: String
}

// 임시 체크목록 아이템
struct ChecklistItem {
    let id: String
    let categoryId: String
    let title: String
    let color: String
    let memo: String
    let status: Bool
    let createdAt: Date
    let repeatCycle: Int
    let endDate: Date
}


class HomeViewModel {
    
    // MARK: - Properties
    var categories: [Category] = Category.generateSampleCategories()
    
    // 임시 이미지 파일
    var tempimagedata: [UIImage] = {
        let imageNames = ["1", "2", "3", "4"]
        return imageNames.compactMap { UIImage(named: $0) } // nil이 아닌 이미지만 반환
    }()
    
    // 체크리스트 임시 데이터
    var checklistItems: [ChecklistItem] = ChecklistItem.generateSampleChecklistItems()
    
    // 날짜 변경 시 호출
    func dateChanged(_ sender: UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = sender.date
        return dateFormatter.string(from: selectedDate)
    }
    
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized)
                }
            }
        default:
            completion(false)
        }
    }
    
    func addImage(_ image: UIImage) {
        tempimagedata.append(image)
    }
    
    func moveImage(from sourceIndex: Int, to destinationIndex: Int) {
        let image = tempimagedata.remove(at: sourceIndex)
        tempimagedata.insert(image, at: destinationIndex)
    }
}

extension Category {
    static func generateSampleCategories() -> [Category] {
        return [
            Category(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                name: "탈모 관리"
            ),
            Category(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                name: "팔자 주름 관리"
            ),
            Category(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                name: "운동 계획"
            ),
            Category(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                name: "식단 관리"
            )
        ]
    }
}

extension ChecklistItem {
    static func generateSampleChecklistItems() -> [ChecklistItem] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Define some sample dates
        let createdDate = dateFormatter.date(from: "2024-01-01") ?? Date()
        let endDate = dateFormatter.date(from: "2024-12-31") ?? Date()
        
        return [
            ChecklistItem(
                id: UUID().uuidString,
                categoryId: "2",
                title: "오메가3 챙겨먹기",
                color: "#FF0000", // Red
                memo: "임시데이터 입니다.",
                status: false,
                createdAt: createdDate,
                repeatCycle: 7, // Weekly
                endDate: endDate
            ),
            ChecklistItem(
                id: UUID().uuidString,
                categoryId: "1",
                title: "립밤 바르기",
                color: "#FF9500", // Blue
                memo: "임시데이터 입니다.",
                status: true,
                createdAt: createdDate,
                repeatCycle: 0, // No repeat
                endDate: endDate
            )
        ]
    }
}
