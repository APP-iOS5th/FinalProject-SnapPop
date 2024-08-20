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
    var categories: [Category] = []
    var checklistItems: [Management] = []
    var tempSnapData: [Snap] = []
    var selectedImageURL: URL?
    var selectedImage: UIImage?
    var isEditingMode: Bool = false
    var selectedSource: ((UIImagePickerController.SourceType) -> Void)?
    
    private let categoryService = CategoryService() // CategoryService 인스턴스
    private let managementService = ManagementService() // ManagementService 인스턴스
    private let snapService = SnapService() // SnapService 인스턴스
    var selectedCategoryId: String? // 선택된 카테고리 ID

    // MARK: - Initialization
    init() {
        // 초기 카테고리 로드
    }
    
    /// 선택된 카테고리에 따라 스냅 데이터와 관리 목록 업데이트
    func updateData(for categoryId: String) {
        self.selectedCategoryId = categoryId
        loadSnaps(for: categoryId) // 카테고리에 해당하��� 스냅 데이터 드
        loadChecklistItems(for: categoryId) // 카테고리에 해당하는 관리 목록 로드
    }
    
    /// 카테고리에 해당하는 스냅 데이터 로드
    private func loadSnaps(for categoryId: String) {
        snapService.loadSnaps(categoryId: categoryId) { result in
            switch result {
            case .success(let snaps):
                self.tempSnapData = snaps
                print("Snaps loaded successfully for category \(categoryId).")
            case .failure(let error):
                print("Error loading snaps: \(error)")
            }
        }
    }
    
    /// 특정 인덱스의 스냅 데이터 삭제
    func deleteSnap(at index: Int) {
        guard index >= 0 && index < tempSnapData.count else { return }
        let snapToDelete = tempSnapData[index]
        
        // Firebase에서 스냅 데이터 삭제
//        guard let categoryId = selectedCategoryId else { return }
        
//        snapService.deleteImage(categoryId: categoryId, snap: snapToDelete.id, imageUrlToDelete: snapToDelete.imageUrls.first ?? "") { result in
//            switch result {
//            case .success:
//                self.tempSnapData.remove(at: index)
//                print("Snap deleted from Firebase successfully.")
//            case .failure(let error):
//                print("Error deleting snap from Firebase: \(error)")
//            }
//        }
    }
    
    /// 편집모드 저장
    func saveEditedData() {
        // Firebase에 업데이트된 스냅 데이터 저장
        saveSnapsToFirebase()
    }
    
    /// Firebase에 스냅 사진 배열 저장
    private func saveSnapsToFirebase() {
        guard let categoryId = selectedCategoryId else { return }
        let imageUrls = tempSnapData.flatMap { $0.imageUrls }
        
        snapService.saveSnap(categoryId: categoryId, imageUrls: imageUrls) { result in
            switch result {
            case .success:
                print("Snaps saved to Firebase successfully.")
            case .failure(let error):
                print("Error saving snaps to Firebase: \(error)")
            }
        }
    }
    
    // MARK: - Management Methods
    /// 카테고리에 해당하는 관리 목록 로드
    private func loadChecklistItems(for categoryId: String) {
        managementService.loadManagements(categoryId: categoryId) { result in
            switch result {
            case .success(let items):
                self.checklistItems = items
                print("Checklist items loaded successfully for category \(categoryId).")
            case .failure(let error):
                print("Error loading checklist items: \(error)")
            }
        }
    }
    
    /// 관리 목록 항목 추가
    func addChecklistItem(_ item: Management) {
        guard let categoryId = selectedCategoryId else { return }
        
        managementService.saveManagement(categoryId: categoryId, management: item) { result in
            switch result {
            case .success:
                self.checklistItems.append(item)
                print("Checklist item added successfully.")
            case .failure(let error):
                print("Error adding checklist item: \(error)")
            }
        }
    }
    
    /// 관리 목록 항목 삭제
    func deleteChecklistItem(at index: Int) {
        guard index >= 0 && index < checklistItems.count else { return }
        let itemToDelete = checklistItems[index]
        
        guard let categoryId = selectedCategoryId else { return }
        
        managementService.deleteManagement(categoryId: categoryId, managementId: itemToDelete.id ?? "") { error in
            if let error = error {
                print("Error deleting checklist item: \(error)")
            } else {
                self.checklistItems.remove(at: index)
                print("Checklist item deleted successfully.")
            }
        }
    }
    
    /// 관리 목��� 항목 업데이트
    func updateChecklistItem(at index: Int, with updatedItem: Management) {
        guard index >= 0 && index < checklistItems.count else { return }
        let itemToUpdate = checklistItems[index]
        
        guard let categoryId = selectedCategoryId else { return }
        
        managementService.updateManagement(categoryId: categoryId, managementId: itemToUpdate.id ?? "", updatedManagement: updatedItem) { result in
            switch result {
            case .success:
                self.checklistItems[index] = updatedItem
                print("Checklist item updated successfully.")
            case .failure(let error):
                print("Error updating checklist item: \(error)")
            }
        }
    }
    
    // MARK: - Image Picker Methods
    func dateChanged(_ sender: UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: sender.date)
    }
    
    /// 스냅 사진 드랍 후 배열 재정의
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
        
        // Firebase에 업데이트된 스냅 사진 배열 저장
        saveSnapsToFirebase()
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
            // Firebase에 스냅 사진 추가 저장
            self.saveSnapsToFirebase()
            completion(true)
        }
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
    
    /// 편집 모드 토글
    func toggleEditingMode() {
        isEditingMode.toggle()
    }
    
    // MARK: - Save Cropped Image
    func saveCroppedImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error converting image to data.")
            return
        }
        
        let placeholderImagePath = "path/to/save/image/\(UUID().uuidString).jpg" // Placeholder URL for the image

        // Create a new Snap object with a placeholder URL
        let newSnap = Snap(id: UUID().uuidString, imageUrls: [placeholderImagePath], createdAt: Date())
        tempSnapData.append(newSnap)

        // Upload the image to Firebase
        snapService.saveImage(data: imageData) { result in
            switch result {
            case .success(let downloadUrl):
                print("Image uploaded successfully: \(downloadUrl)")
                
                // Replace the placeholder URL with the actual download URL
                if let index = self.tempSnapData.firstIndex(where: { $0.id == newSnap.id }) {
                    // Create a new Snap object with the updated URL
                    let updatedSnap = Snap(id: newSnap.id, imageUrls: [downloadUrl], createdAt: newSnap.createdAt)
                    
                    // Replace the old Snap object with the updated one
                    self.tempSnapData[index] = updatedSnap
                    
                    // Save the updated Snap data to Firebase
                    self.saveSnapDataToFirebase()
                }
            case .failure(let error):
                print("Error uploading image: \(error)")
            }
        }
    }
    
    // MARK: - Save Snap Data to Firebase
    func saveSnapDataToFirebase() {
        guard let categoryId = selectedCategoryId else { return }
        
        // Extract image URLs from tempSnapData
        let imageUrls = tempSnapData.flatMap { $0.imageUrls }
        
        // Call the SnapService to save the Snap data
        snapService.saveSnap(categoryId: categoryId, imageUrls: imageUrls) { result in
            switch result {
            case .success:
                print("Snaps saved to Firebase successfully.")
                // Optionally, you can reload the snaps after saving
                self.loadSnaps(for: categoryId) // Reload snaps to update the UI
            case .failure(let error):
                print("Error saving snaps to Firebase: \(error)")
            }
        }
    }
    
    // MARK: - Load Snaps
//    func loadSnaps(for categoryId: String) {
//        snapService.loadSnaps(categoryId: categoryId) { result in
//            switch result {
//            case .success(let snaps):
//                self.tempSnapData = snaps
//                print("Snaps loaded successfully for category \(categoryId).")
//                // Notify the UI to refresh (if using a delegate or notification)
//            case .failure(let error):
//                print("Error loading snaps: \(error)")
//            }
//        }
//    }
}
