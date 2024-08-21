//
//  File.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/8/24.
//

import UIKit
import Photos
import AVFoundation
import Combine

// MARK: - ViewModel
class HomeViewModel: ObservableObject {
    
    private let snapService = SnapService()
    private let managementService = ManagementService() // ManagementService 인스턴스
    // MARK: - Properties
    @Published var checklistItems: [Management] = []
    @Published var snapData: [Snap] = []
    var selectedSource: ((UIImagePickerController.SourceType) -> Void)?
    var selectedCategoryId: String? // 선택된 카테고리 ID

    // MARK: - Initialization
    init() {
        //loadChecklistItems() // 초기 로드
    }
    /// Image Picker Methods
    func dateChanged(_ sender: UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: sender.date)
    }
    
    // 이미지와 assetIdentifier를 저장하는 메서드 예제
    func saveCroppedSnapData(image: UIImage, assetIdentifier: String, categoryId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // assetIdentifier를 문자열 배열로 변환
        let imageUrls = [assetIdentifier]
        
        // `saveSnap` 함수를 호출하여 Firestore에 저장합니다.
        snapService.saveSnap(categoryId: categoryId, imageUrls: imageUrls) { result in
            switch result {
            case .success():
                print("Snap 저장 성공")
                completion(.success(()))
            case .failure(let error):
                print("Snap 저장 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // 스냅 사진 드랍 후 배열 재정의
//    func droptoSnapUpdate(from sourceIndex: Int, to destinationIndex: Int) {
//        guard sourceIndex != destinationIndex, sourceIndex < snapData.count else { return }
//        
//        let itemToMove = snapData[sourceIndex]
//        snapData.remove(at: sourceIndex)
//        
//        if destinationIndex >= snapData.count {
//            snapData.append(itemToMove)
//        } else {
//            snapData.insert(itemToMove, at: destinationIndex)
//        }
//        
//        print("Item moved from index \(sourceIndex) to \(destinationIndex)")
//        print("Updated tempSnapData: \(snapData)")
//        
//        // Firebase에 업데이트된 스냅 사진 배열 저장
//        saveSnapsToFirebase()
//    }
//    
//    func saveSnapsToFirebase() {
//        guard let categoryId = selectedCategoryId else { return }
//        
//        // Extract image URLs from tempSnapData
//        let imageUrls = snapData.flatMap { $0.imageUrls }
//        
//        // Call the SnapService to save the Snap data
//        snapService.saveSnap(categoryId: categoryId, imageUrls: imageUrls) { result in
//            switch result {
//            case .success:
//                print("Snaps saved to Firebase successfully.")
//            case .failure(let error):
//                print("Error saving snaps to Firebase: \(error)")
//            }
//        }
//    }
//    
    // 스냅 사진 삭제 기능
    func deletePhoto(categoryId: String, snap: Snap, imageUrlToDelete: String, completion: @escaping (Result<Void, Error>) -> Void) {
        snapService.deleteImage(categoryId: categoryId, snap: snap, imageUrlToDelete: imageUrlToDelete) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 스냅 로드 기능
    func loadSnap(categoryId: String, snapDate: Date, completion: @escaping (Result<Snap, Error>) -> Void) {
        snapService.loadSnap(categoryId: categoryId, snapDate: snapDate, completion: completion)
    }
    
    // 스냅 리스트 로드 기능
//    func loadSnaps() {
////        guard let categoryId = navigationViewModel.currentCategory?.id else {
////            print("Category ID is missing.")
////            return
////        }
//
//        snapService.loadSnaps(categoryId: "kzbh5r58xqs95cl2sXEK") { [weak self] result in
//            switch result {
//            case .success(let snaps):
//                DispatchQueue.main.async {
//                    // PHAsset 관련 기능 제거
//                    self?.snapData = snaps // Snap 객체를 그대로 사용
//                    print("Snaps loaded successfully.")
//                }
//            case .failure(let error):
//                print("Error loading snaps: \(error.localizedDescription)")
//            }
//        }
//    }
    
    func loadSnaps() {
        let categoryId = "kzbh5r58xqs95cl2sXEK"
        let snapDate = Date() // 여기서는 현재 날짜를 사용, 필요에 따라 변경 가능

        snapService.loadSnap(categoryId: categoryId, snapDate: snapDate) { [weak self] result in
            switch result {
            case .success(let snap):
                DispatchQueue.main.async {
                    // 단일 Snap 객체를 snapData 배열에 추가 (또는 배열 전체를 교체)
                    self?.snapData = [snap] // Snap 객체를 배열로 만들어 사용
                    print("Snap loaded successfully.")
                }
            case .failure(let error):
                print("Error loading snap: \(error.localizedDescription)")
            }
        }
    }
    

//    // 체크리스트 아이템 로드
//    func loadChecklistItems() {
//        guard let categoryId = navigationViewModel.currentCategoryId else {
//            print("Category ID is missing.")
//            return
//        }
//        
//        managementService.loadManagements(categoryId: categoryId) { [weak self] result in
//            switch result {
//            case .success(let items):
//                DispatchQueue.main.async {
//                    self?.checklistItems = items // Combine을 통해 UI에 자동으로 반영
//                    print("Checklist items loaded successfully.")
//                }
//            case .failure(let error):
//                print("Error loading checklist items: \(error.localizedDescription)")
//            }
//        }
//    }

        
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
    
    // MARK: - Permission Methods
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
    
    /// 캘러리 접근 제한 명령 메소드
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
    
//    // 체크리스트 아이템 저장
//    func saveChecklistItem(_ item: Management) {
//        guard let categoryId = selectedCategoryId else {
//            print("Category ID is missing.")
//            return
//        }
//        
//        managementService.saveManagement(categoryId: categoryId, management: item) { [weak self] result in
//            switch result {
//            case .success:
//                print("Checklist item saved successfully.")
//                self?.loadChecklistItems() // 저장 후 로드
//            case .failure(let error):
//                print("Error saving checklist item: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    // 체크리스트 아이템 삭제
//    func deleteChecklistItem(at index: Int) {
//        guard index < checklistItems.count else { return }
//        
//        let itemToDelete = checklistItems[index]
//        
//        managementService.deleteManagement(itemId: itemToDelete.id) { [weak self] result in
//            switch result {
//            case .success:
//                print("Checklist item deleted successfully.")
//                self?.checklistItems.remove(at: index) // 로컬에서 삭제
//            case .failure(let error):
//                print("Error deleting checklist item: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    // 체크리스트 아이템 로드
//    func loadChecklistItems() {
//        managementService.loadManagements(categoryId: <#String#>) { [weak self] result in
//            switch result {
//            case .success(let items):
//                DispatchQueue.main.async {
//                    self?.checklistItems = items // Combine을 통해 UI에 자동으로 반영
//                    print("Checklist items loaded successfully.")
//                }
//            case .failure(let error):
//                print("Error loading checklist items: \(error.localizedDescription)")
//            }
//        }
//    }
}

// PHAsset을 가져오는 메서드
private func fetchPHAsset(for snap: Snap) -> PHAsset? {
    // PHAsset을 가져오는 로직을 구현합니다.
    // 예를 들어, imageUrls를 사용하여 PHAsset을 찾는 방법을 구현할 수 있습니다.
    return nil // 실제 구현 필요
}
