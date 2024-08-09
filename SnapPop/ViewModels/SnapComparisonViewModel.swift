//
//  SnapComparisonViewModel.swift
//  SnapPop
//
//  Created by 정종원 on 8/8/24.
//

import Foundation
import UIKit

struct Snap {
    let date: String
    let images: [UIImage]
}

class SnapComparisonViewModel {
    // MARK: - Properties
    // TODO: - 이후 이미지는 이미지URL로 바꾸는 작업 필요
    private var mockData: [Snap] = [
        Snap(date: "2024년 3월 12일", images: [UIImage(systemName: "person.fill")!,
                                            UIImage(systemName: "globe")!,
                                            UIImage(systemName: "person.fill")!,
                                            UIImage(systemName: "person.fill")!,
                                            UIImage(systemName: "person.fill")!,
                                            UIImage(systemName: "person.fill")!,
                                            UIImage(systemName: "person.fill")!,
                                            UIImage(systemName: "person.fill")!,
                                            UIImage(systemName: "person.fill")!]),
        Snap(date: "2024년 8월 24일", images: [UIImage(systemName: "person.fill")!, UIImage(systemName: "person.fill")!]),
        Snap(date: "2024년 8월 24일", images: [UIImage(systemName: "person.fill")!, UIImage(systemName: "person.fill")!]),
        Snap(date: "2024년 8월 24일", images: [UIImage(systemName: "person.fill")!, UIImage(systemName: "person.fill")!]),
        Snap(date: "2024년 8월 24일", images: [UIImage(systemName: "person.fill")!, UIImage(systemName: "person.fill")!])
    ]
    var filteredSnapData: [Snap] = []
    var snapPhotoSelectionType: String = "전체" {
        didSet {
            filterSnaps()
        }
    }
    var snapPeriodType: String = "전체" {
        didSet {
            filterSnaps()
        }
    }
    
    init() {
        filterSnaps()
    }
    
    // MARK: - Methods
    /// 스냅 데이터 필터링 메소드
    func filterSnaps() {
        filteredSnapData = mockData
        
        if snapPeriodType != "전체" {
            // ↓TODO: 기간에 따른 필터링
        }
        
        if snapPhotoSelectionType == "메인 사진" {
            filteredSnapData = filteredSnapData.map({ snap in
                Snap(date: snap.date, images: Array(snap.images.prefix(1)))
            })
        }
        
    }
    
    func item(at indexPath: IndexPath) -> Snap {
        return filteredSnapData[indexPath.section]
    }
    
    /// snapPhotoSelectionType을 정해주는 메소드
    func changeSnapPhotoSelection(type: String, completion: @escaping () -> Void) {
        self.snapPhotoSelectionType = type
        completion()
    }
    
    /// snapPeriodType을 정해주는 메소드
    func changeSnapPeriod(type: String, completion: @escaping () -> Void) {
        self.snapPeriodType = type
        completion()
    }
    
    func numberOfSections() -> Int {
        filteredSnapData.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        1
    }
}
