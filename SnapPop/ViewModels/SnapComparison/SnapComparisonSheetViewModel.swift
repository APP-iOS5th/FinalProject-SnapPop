//
//  SnapComparisonSheetViewModel.swift
//  SnapPop
//
//  Created by 정종원 on 8/14/24.
//

import Foundation
import UIKit
import Kingfisher

protocol SnapComparisonSheetViewModelProtocol {
    var filteredSnapData: [Snap] { get set}
    var selectedIndex: Int { get set}
    var currentDateIndex: Int { get set}
    var currentPhotoIndex: Int { get set}
    var currentSnap: Snap { get }
    var isLeftArrowHidden: Bool { get }
    var isRightArrowHidden: Bool { get }
    
    var updateUI: (() -> Void)? { get set }
    var updatePageControl: ((Int, Int) -> Void)? { get set }
    var updateArrowVisibility: ((Bool, Bool) -> Void)? { get set }
    func updateSnapData()
    func getSnapPhoto(at index: Int, completion: @escaping (UIImage?) -> Void)
    func moveToPreviousSnap()
    func moveToNextSnap()
}

class SnapComparisonSheetViewModel: SnapComparisonSheetViewModelProtocol {
    // MARK: - Properties
    var filteredSnapData: [Snap] = []
    var selectedIndex: Int = 0
    var currentDateIndex: Int = 0
    /// 페이지뷰 컨트롤러 인덱스
    var currentPhotoIndex: Int = 0
    var currentSnap: Snap {
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
        updatePageControl?(currentPhotoIndex, currentSnap.imageUrls.count)
        updateArrowVisibility?(isLeftArrowHidden, isRightArrowHidden)
    }
    
    func getSnapPhoto(at index: Int, completion: @escaping (UIImage?) -> Void) {
        guard index >= 0, index < currentSnap.imageUrls.count  else {
            completion(UIImage(systemName: "circle.dotted"))
            return
        }
        
//        if let url = URL(string: currentSnap.imageUrls[index]) {
//            let image = UIImage.loadImage(from: url)
//            return image
//        }
        if let url = URL(string: currentSnap.imageUrls[index]) {
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    completion(value.image)
                case .failure:
                    completion(UIImage(systemName: "circle.dotted"))
                }
            }
        } else {
            completion(UIImage(systemName: "circle.dotted"))
        }
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
