//
//  SnapComparisonSheetViewModel.swift
//  SnapPop
//
//  Created by 정종원 on 8/14/24.
//

import Foundation
import UIKit

protocol SnapComparisonSheetViewModelProtocol {
    var filteredSnapData: [MockSnap] { get set}
    var selectedIndex: Int { get set}
    var currentDateIndex: Int { get set}
    var currentPhotoIndex: Int { get set}
    var currentSnap: MockSnap { get }
    var isLeftArrowHidden: Bool { get }
    var isRightArrowHidden: Bool { get }
    
    var updateUI: (() -> Void)? { get set }
    var updatePageControl: ((Int, Int) -> Void)? { get set }
    var updateArrowVisibility: ((Bool, Bool) -> Void)? { get set }
    func updateSnapData()
    func getSnapPhoto(at index: Int) -> UIImage?
    func moveToPreviousSnap()
    func moveToNextSnap()
}

class SnapComparisonSheetViewModel: SnapComparisonSheetViewModelProtocol {
    // MARK: - Properties
    var filteredSnapData: [MockSnap] = []
    var selectedIndex: Int = 0
    var currentDateIndex: Int = 0
    /// 페이지뷰 컨트롤러 인덱스
    var currentPhotoIndex: Int = 0
    var currentSnap: MockSnap {
        guard currentDateIndex >= 0, currentDateIndex < filteredSnapData.count else {
            print("currentDateIndex: \(currentDateIndex), filteredSnapData.count: \(filteredSnapData.count)")
            fatalError("currentDateIndex가 잘못된 범위를 참조하고 있습니다.")
        }
        return filteredSnapData[currentDateIndex]
    }
    var isLeftArrowHidden: Bool {
        return currentDateIndex == 0
    }
    var isRightArrowHidden: Bool {
        return currentDateIndex == filteredSnapData.count - 1
    }
    
    // MARK: - Methods
    
    // 클로저
    var updateUI: (() -> Void)?
    var updatePageControl: ((Int, Int) -> Void)?
    var updateArrowVisibility: ((Bool, Bool) -> Void)?
    
    func updateSnapData() {
        updateUI?()
        updatePageControl?(currentPhotoIndex, currentSnap.images.count)
        updateArrowVisibility?(isLeftArrowHidden, isRightArrowHidden)
    }
    
    func getSnapPhoto(at index: Int) -> UIImage? {
        guard index >= 0, index < currentSnap.images.count  else {
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
