//
//  File.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/8/24.
//

import Foundation
import UIKit
import Photos

class HomeViewModel {
    
    // MARK: - Properties
    var categories: [String] {
        return ["탈모 관리", "팔자 주름 관리"]
    }
    
    // 임시 파일
    var tempimagedata: [UIImage] = {
        let imageNames = ["1", "2", "3", "4"]
        return imageNames.compactMap { UIImage(named: $0) } // nil이 아닌 이미지만 반환
    }()

    
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
