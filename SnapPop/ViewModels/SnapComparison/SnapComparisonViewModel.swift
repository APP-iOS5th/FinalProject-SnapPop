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
        Snap(date: "2024년 8월 1일", images: [UIImage(systemName: "person.fill")!, UIImage(systemName: "person.fill")!]),
        Snap(date: "2024년 8월 2일", images: [UIImage(systemName: "person.fill")!, UIImage(systemName: "person.fill")!]),
        Snap(date: "2024년 8월 3일", images: [UIImage(systemName: "person.fill")!, UIImage(systemName: "person.fill")!]),
        Snap(date: "2024년 8월 4일", images: [UIImage(systemName: "person.fill")!, UIImage(systemName: "person.fill")!])
    ]
    var filteredSnapData: [Snap] = []
    var snapPhotoSelectionType: String = "전체" {
        didSet {
            filterSnaps()
            updateSnapPhotoButtonTitle?(snapPhotoSelectionType)
        }
    }
    var snapPeriodType: String = "전체" {
        didSet {
            filterSnaps()
            updateSnapPeriodButtonTitle?(snapPeriodType)
        }
    }
    /// 컬렉션뷰 reload 클로저
    var reloadCollectionView: (() -> Void)?
    /// 스냅 사진 선택 메뉴
    var snapPhotoMenuItems: [UIAction] {
        let allSnapPhoto = UIAction(
            title: "전체",
            handler: { [weak self] _ in
                self?.changeSnapPhotoSelection(type: "전체") {
                    self?.reloadCollectionView?()
                }
            })
        
        let mainSnapPhoto = UIAction(
            title: "메인 사진",
            handler: { [weak self] _ in
                self?.changeSnapPhotoSelection(type: "메인 사진") {
                    self?.reloadCollectionView?()
                }
            })
        
        return [mainSnapPhoto, allSnapPhoto]
    }
    /// 스냅 주기 선택 메뉴
    var snapPeriodMenuItems: [UIAction] {
        let perWeek = UIAction(
            title: "일주일",
            handler: { [weak self] _ in
                self?.changeSnapPeriod(type: "일주일") {
                    self?.reloadCollectionView?()
                }
            })
        
        let perMonth = UIAction(
            title: "한달",
            handler: { [weak self] _ in
                self?.changeSnapPeriod(type: "한달") {
                    self?.reloadCollectionView?()
                }
            })
        
        let perYear = UIAction(
            title: "일년",
            handler: { [weak self] _ in
                self?.changeSnapPeriod(type: "일년") {
                    self?.reloadCollectionView?()
                }
            })
        
        let allPeriod = UIAction(
            title: "전체",
            handler: { [weak self] _ in
                self?.changeSnapPeriod(type: "전체") {
                    self?.reloadCollectionView?()
                }
            })
        
        return [perWeek, perMonth, perYear, allPeriod]
    }
    /// 버튼 타이틀 업데이트 클로저
    var updateSnapPhotoButtonTitle: ((String) -> Void)?
    /// 버튼 타이틀 업데이트 클로저
    var updateSnapPeriodButtonTitle: ((String) -> Void)?
    
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
    
    // MARK: - SnapComparisonSheetViewController Properties
    var selectedIndex: Int = 0
    var currentDateIndex: Int = 0
    var currentPhotoIndex: Int = 0
    var currentSnap: Snap? {
        return filteredSnapData[currentDateIndex]
    }
    var isLeftArrowHidden: Bool {
        return currentDateIndex == 0
    }
    var isRightArrowHidden: Bool {
        return currentDateIndex == filteredSnapData.count - 1
    }
    
    // 클로저
    var updateUI: (() -> Void)?
    var updatePageControl: ((Int, Int) -> Void)?
    var updateArrowVisibility: ((Bool, Bool) -> Void)?
    
    // MARK: - SnapComparisonSheetViewController Methods
    
    func updateSnapData() {
        updateUI?()
        updatePageControl?(currentPhotoIndex, currentSnap?.images.count ?? 0)
        updateArrowVisibility?(isLeftArrowHidden, isRightArrowHidden)
    }
    
    func getSnapPhoto(at index: Int) -> UIImage? {
        guard let currentSnap = currentSnap,
              index >= 0,
              index < currentSnap.images.count else {
            return nil
        }
        return currentSnap.images[index]
    }
    
    func moveToPreviousSnap() {
        guard currentDateIndex > 0 else { return }
        currentDateIndex -= 1
        currentPhotoIndex = 0
        updateSnapData()
    }
    
    func moveToNextSnap() {
        guard currentDateIndex < filteredSnapData.count - 1 else { return }
        currentDateIndex += 1
        currentPhotoIndex = 0
        updateSnapData()
    }
}
