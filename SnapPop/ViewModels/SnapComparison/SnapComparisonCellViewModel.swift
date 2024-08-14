//
//  SnapComparisonCellViewModel.swift
//  SnapPop
//
//  Created by 정종원 on 8/14/24.
//

import Foundation
import UIKit

class SnapComparisonCellViewModel {
    // MARK: - Properties
    var snapPhotos: [UIImage] = []
    /// 현재 섹션의 인덱스 저장 변수
    var currentSectionIndex: Int = 0
    var filteredSnapData: [Snap] = []
    
    // MARK: - Methods
    func numberOfSections() -> Int {
        snapPhotos.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        1
    }
}
