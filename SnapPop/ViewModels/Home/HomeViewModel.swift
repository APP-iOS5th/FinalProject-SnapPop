//
//  File.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/8/24.
//

import Foundation
import UIKit

// MARK: - ViewModel
class HomeViewModel {
    
    // MARK: - Properties
    var categories: [Category] = Category.generateSampleCategories()
    var checklistItems: [Management] = Management.generateSampleManagementItems()
    var selectedImageURL: URL?
    var selectedImage: UIImage?
    var tempSnapData: [Snap] = []
    
    // 선택된 카메라 소스
    var selectedSource: ((UIImagePickerController.SourceType) -> Void)?
    
    // MARK: - Methods
    func dateChanged(_ sender: UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: sender.date)
    }
    
    // MARK: 액션시트에 선택된 옵션에 따른 처리 메소드
    func imagepickerActionSheet(from viewController: UIViewController) {
        let actionSheet = UIAlertController(title: "사진 선택", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "카메라", style: .default) { _ in
                self.selectedSource?(.camera)
            })
        }
    
        actionSheet.addAction(UIAlertAction(title: "갤러리", style: .default) { _ in
            self.selectedSource?(.photoLibrary)
        })
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: 선택된 이미지 처리 메소드
    private func handleImageSource(_ sourceType: UIImagePickerController.SourceType, from viewController: UIViewController) {
           let imagePickerController = UIImagePickerController()
           imagePickerController.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
           imagePickerController.sourceType = sourceType
           
           viewController.present(imagePickerController, animated: true, completion: nil)
       }
}
