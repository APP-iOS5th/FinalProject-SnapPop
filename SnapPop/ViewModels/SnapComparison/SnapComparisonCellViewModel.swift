//
//  SnapComparisonCellViewModel.swift
//  SnapPop
//
//  Created by 정종원 on 8/14/24.
//

import Foundation
import UIKit

protocol SnapComparisonCellViewModelProtocol {
    var snapPhotos: [UIImage] { get set }
    var currentSectionIndex: Int { get set }
    var filteredSnapData: [MockSnap] { get set }
    var numberOfSections: Int { get }
    func numberOfRows(in section: Int) -> Int
}

class SnapComparisonCellViewModel: SnapComparisonCellViewModelProtocol {
    // MARK: - Properties
    var snapPhotos: [UIImage] = []
    /// 현재 섹션의 인덱스 저장 변수
    var currentSectionIndex: Int = 0
    var filteredSnapData: [MockSnap] = []
    var numberOfSections: Int {
        snapPhotos.count
    }
    
    // MARK: - Methods
    func numberOfRows(in section: Int) -> Int {
        1
    }
}
