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
import FirebaseFirestore

// MARK: - ViewModel
class HomeViewModel: ObservableObject, CategoryChangeDelegate {    
    
    private let snapService: SnapService
    private let managementService = ManagementService() // ManagementService 인스턴스
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Properties
    var filteredSnapData: [Snap] = []
    @Published var checklistItems: [Management] = []
    @Published var snap: Snap?
    @Published var selectedCategoryId: String?
    var selectedSource: ((UIImagePickerController.SourceType) -> Void)?
    
    // MARK: - Initialization
    init(snapService: SnapService) {
        self.snapService = snapService
        self.selectedCategoryId = UserDefaults.standard.string(forKey: "currentCategoryId")
    }
    /// Image Picker Methods
    func dateChanged(_ sender: UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: sender.date)
    }
    
    func addManagement(_ management: Management) {
        checklistItems.append(management)
    }
    // 관리 불러오기
    func fetchManagements(categoryId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        managementService.loadManagements(categoryId: categoryId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let managements):
                    self?.checklistItems = managements
                    print("Fetched managements: \(managements)")
                    completion(.success(()))
                case .failure(let error):
                    print("Error fetching managements: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    // 관리 삭제
    func deleteManagement(categoryId: String, managementId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        managementService.deleteManagement(categoryId: categoryId, managementId: managementId) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    // 관리 편집 후 업데이트
    func updateManagement(categoryId: String, managementId: String, updatedManagement: Management, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = ManagementService()
        db.updateManagement(categoryId: categoryId, managementId: managementId, updatedManagement: updatedManagement) { result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    if let index = self.checklistItems.firstIndex(where: { $0.id == managementId }) {
                        self.checklistItems[index] = updatedManagement
                    }
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    
    // 스냅 저장
    func saveSnap(categoryId: String, images: [UIImage], createdAt: Date, completion: @escaping (Result<Snap, Error>) -> Void) {
        var imageUrls: [String?] = Array(repeating: nil, count: images.count)
        let group = DispatchGroup()
        
        for (index, image) in images.enumerated() {
            if let data = image.jpegData(compressionQuality: 1.0) {
                group.enter()
                snapService.saveImage(data: data) { result in
                    switch result {
                    case .success(let url):
                        imageUrls[index] = url
                    case .failure(let error):
                        completion(.failure(error))
                        group.leave()
                        return
                    }
                    group.leave()
                }
            }
        }
    
        // 모든 이미지 업로드 성공시에만 호출됨
        group.notify(queue: .main) {
            let finalImageUrls = imageUrls.compactMap { $0 }

            if finalImageUrls.count == images.count {
                self.snapService.saveSnap(categoryId: categoryId, imageUrls: finalImageUrls, createdAt: createdAt) { result in
                    switch result {
                    case .success(let snap):
                        let now = Date()  // 현재 날짜와 시간을 나타내는 Date 객체 생성
                        let calendar = Calendar.current
                        let hour = calendar.component(.hour, from: now)   // 현재 시간
                        
                        // 기존 알림은 지우고 새로운 스냅 알림 등록
                        NotificationManager.shared.removeNotification(identifiers: ["dailySnapNotification"])
                        NotificationManager.shared.scheduleDailySnapNotification(hour: hour)
                        
                        completion(.success(snap))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    // 스냅 로드
    func loadSnap(categoryId: String, snapDate: Date, completion: @escaping () -> Void) {
        snapService.loadSnap(categoryId: categoryId, snapDate: snapDate) { result in
            switch result {
            case .success(let snap):
                self.snap = snap
                
                self.filteredSnapData.removeAll()
                
                if !snap.imageUrls.isEmpty { 
                    self.filteredSnapData.append(snap)
                }
                
                completion()
            case .failure(let error):
                print("스냅 로드 실패: \(error.localizedDescription)")
                self.snap = nil
                completion()
            }
        }
    }
    
    // 스냅 업데이트 (기존에 이미 사진이 있는데 사진을 더 추가)
    func updateSnap(categoryId: String, snap: Snap, newImages: [UIImage], completion: @escaping (Result<Snap, Error>) -> Void) {
        var imageUrls: [String?] = Array(repeating: nil, count: newImages.count)
        let group = DispatchGroup()
        
        for (index, image) in newImages.enumerated() {
            if let data = image.jpegData(compressionQuality: 1.0) {
                group.enter()
                snapService.saveImage(data: data) { result in
                    switch result {
                    case .success(let url):
                        imageUrls[index] = url
                    case .failure(let error):
                        completion(.failure(error))
                        group.leave()
                        return
                    }
                    group.leave()
                }
            }
        }
    
        // 모든 이미지 업로드 성공시에만 호출됨
        group.notify(queue: .main) {
            let finalImageUrls = imageUrls.compactMap { $0 }

            if finalImageUrls.count == newImages.count {
                self.snapService.updateSnap(categoryId: categoryId, snap: snap, newImageUrls: finalImageUrls) { result in
                    switch result {
                    case .success(let snap):
                        completion(.success(snap))
                    case .failure(let error):
                        print("스냅 업데이트 실패: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    // 스냅 사진 삭제
    func deleteImage(categoryId: String, snap: Snap, imageUrlToDelete: String, completion: @escaping (Result<Void, Error>) -> Void) {
        snapService.deleteImage(categoryId: categoryId, snap: snap, imageUrlToDelete: imageUrlToDelete) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 스냅 자체를 삭제
    func deleteSnap(categoryId: String, snap: Snap) {
        snapService.deleteSnap(categoryId: categoryId, snap: snap) { error in
            if let error = error {
                print("스냅 삭제 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - CategoryChangeDelegate
    func categoryDidChange(to newCategoryId: String?) {
        self.selectedCategoryId = newCategoryId
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
}
