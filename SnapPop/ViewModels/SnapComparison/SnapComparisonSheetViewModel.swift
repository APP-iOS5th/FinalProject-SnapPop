//
//  SnapComparisonSheetViewModel.swift
//  SnapPop
//
//  Created by 정종원 on 8/14/24.
//

import Foundation
import UIKit

class SnapComparisonSheetViewModel {
    // MARK: - Properties
    var filteredSnapData: [Snap] = []
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
    
    // MARK: - Methods
    
    // 클로저
    var updateUI: (() -> Void)?
    var updatePageControl: ((Int, Int) -> Void)?
    var updateArrowVisibility: ((Bool, Bool) -> Void)?
    
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
