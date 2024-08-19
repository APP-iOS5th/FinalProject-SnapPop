//
//  File.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/8/24.
//

import UIKit
import Photos
import AVFoundation

// MARK: - ViewModel
class HomeViewModel {
    
    // MARK: - Properties
    var categories: [Category] = Category.generateSampleCategories()
    var checklistItems: [Management] = Management.generateSampleManagementItems()
    var tempSnapData: [Snap] = Snap.sampleData()
    var selectedImageURL: URL?
    var selectedImage: UIImage?
    
    /// 선택된 카메라 소스
    var selectedSource: ((UIImagePickerController.SourceType) -> Void)?
    
    // MARK: - Methods
    func dateChanged(_ sender: UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: sender.date)
    }
    
    /// 스냅 사진 드랍   후 배열 재정의
    func droptoSnapUpdate(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex, sourceIndex < tempSnapData.count else { return }
        
        let itemToMove = tempSnapData[sourceIndex]
        tempSnapData.remove(at: sourceIndex)
                               
        if destinationIndex >= tempSnapData.count {
            tempSnapData.append(itemToMove)
        } else {
            tempSnapData.insert(itemToMove, at: destinationIndex)
        }
        
        print("Item moved from index \(sourceIndex) to \(destinationIndex)")
        print("Updated tempSnapData: \(tempSnapData)")
    }
    
    
    
    /// 액션시트에 선택된 옵션에 따른 처리 메소드
    func showImagePickerActionSheet(from viewController: UIViewController) {
        let actionSheet = UIAlertController(title: "사진 선택", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "카메라", style: .default) { [weak self] _ in
                self?.requestCameraAccess { granted in
                    DispatchQueue.main.async {
                        if granted {
                            self?.selectedSource?(.camera)
                        } else {
                            self?.showPermissionDeniedAlert(for: "카메라", on: viewController)
                        }
                    }
                }
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionSheet.addAction(UIAlertAction(title: "갤러리", style: .default) { [weak self] _ in
                self?.requestPhotoLibraryAccess { granted in
                    DispatchQueue.main.async {
                        if granted {
                            self?.selectedSource?(.photoLibrary)
                        } else {
                            self?.showPermissionDeniedAlert(for: "사진 라이브러리", on: viewController)
                        }
                    }
                }
            })
        }
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    // 이미지 소스를 선택하고, 선택한 소스(카메라 또는 갤러리)에 따라 UIImagePickerController를 설정
    func handleImageSource(_ sourceType: UIImagePickerController.SourceType, from viewController: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.sourceType = sourceType
        
        viewController.present(imagePickerController, animated: true, completion: nil)
    }
    
    // Fetch photo details from URL 메소드
    func fetchPhotoDetails(from url: URL, completion: @escaping (Bool) -> Void) {
        let assets = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
        var fetchedSnapData: [Snap] = []
        
        assets.enumerateObjects { asset, _, _ in
            let creationDate = asset.creationDate ?? Date()
            let localIdentifier = asset.localIdentifier
            let imageUrl = url.absoluteString
            let snap = Snap(id: localIdentifier, imageUrls: [imageUrl], createdAt: creationDate)
            
            fetchedSnapData.append(snap)
        }
        
        DispatchQueue.main.async {
            self.tempSnapData.append(contentsOf: fetchedSnapData)
            completion(true)
        }
    }
    
    // 카메라 접근 제한 명령 메소드
    func requestCameraAccess(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized || status == .limited)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    // 권한 거부 알림 표시
    func showPermissionDeniedAlert(for feature: String, on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "권한 필요",
            message: "\(feature) 접근 권한이 필요합니다. 설정에서 권한을 변경해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        viewController.present(alert, animated: true)
    }
}
