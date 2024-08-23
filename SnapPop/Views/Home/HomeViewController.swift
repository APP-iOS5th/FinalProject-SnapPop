//
//  HomeViewController.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/8/24.
//

import UIKit
import SwiftUI
import Photos
import MobileCoreServices
import Combine
import PhotosUI

extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let vc: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return vc
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
    
    func toPreview() -> some View {
        Preview(vc: self)
    }
}

class HomeViewController:
    UIViewController,
    UINavigationControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {
    
    // ViewModel
    private var viewModel = HomeViewModel(snapService: SnapService())
    var navigationBarViewModel: CustomNavigationBarViewModelProtocol // 프로퍼티로 선언
    
    // MARK: - Properties
    // 선택한 사진의 순서에 맞게 Identifier들을 배열로 저장
    private var selections = [String : PHPickerResult]()
    private var selectedAssetIdentifiers = [String]()
    
    // MARK: - Initializers
    init(navigationBarViewModel: CustomNavigationBarViewModelProtocol) {
        self.navigationBarViewModel = navigationBarViewModel
        super.init(nibName: nil, bundle: nil) // 부모 클래스 초기화
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 스토리보드 사용 시 필요
    }
    
    // DatePicker UI 요소
    private let customDatePickerViewController = CustomDatePickerViewController()
    
    // 스냅 타이틀
    private let snapTitle: UILabel = {
        let label = UILabel()
        label.text = "Snap Pop"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var isEditingMode = false
    
    // 편집 버튼
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("편집", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 이미지 추가 버튼
    private let addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.customButtonColor
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 선택된 이미지를 저장할 속성
    private var selectedImage: UIImage?
    
    // 관리 목록 타이틀
    private let managementTitle: UILabel = {
        let label = UILabel()
        label.text = "관리 목록"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 스냅 컬렉션
    private let snapCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // 체크리스트 테이블
    private let checklistTableViewController = ChecklistTableViewController()
    
    // Add a property to hold the cancellables
    private var cancellables = Set<AnyCancellable>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.customBackgroundColor
        setupdatepickerView()
        setupSnapCollectionView()
        setupChecklistView()
        
        snapCollectionView.dataSource = self
        snapCollectionView.delegate = self
        
        // Add a button to show the date picker
//        let datePickerButton = UIButton(type: .system)
//        datePickerButton.setTitle("날짜 선택", for: .normal)
//        datePickerButton.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
//        datePickerButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(datePickerButton)
//        
//        // Set constraints for the datePickerButton
//        NSLayoutConstraint.activate([
//            datePickerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            datePickerButton.topAnchor.constraint(equalTo: managementTitle.bottomAnchor, constant: 20) // Adjust as needed
//        ])
        
        viewModel.selectedSource = { [weak self] sourceType in
            guard let self = self else { return }
            self.viewModel.handleImageSource(sourceType, from: self)
        }
        
        // 카테고리 로드
        navigationBarViewModel.loadCategories { [weak self] in
            // 카테고리 로드 후 UI 업데이트
            self?.updateUIWithCategories()
        }

        if let navigationController = self.navigationController as? CustomNavigationBarController {
            navigationController.viewModel.delegate = viewModel as? CategoryChangeDelegate
        }
        
        viewModel.$selectedCategoryId.sink { [weak self] selectedCategoryId in
            guard let self = self, let categoryId = selectedCategoryId else { return }
            
            viewModel.loadSnap(categoryId: categoryId, snapDate: self.customDatePickerViewController.selectedDate) { [weak self] in
                self?.updateSnapCollectionView()
            }
        }.store(in: &cancellables)
    }
    
    @objc private func updateSnapCollectionView() {
        DispatchQueue.main.async {
            self.snapCollectionView.reloadData() // UI 업데이트
        }
    }
    

    // MARK: - 날짜 변경 시 호출
    @objc private func dateChanged(_ sender: UIDatePicker) {
        guard let categoryId = viewModel.selectedCategoryId else { return }
        
        viewModel.loadSnap(categoryId: categoryId, snapDate: sender.date) { [weak self] in
            self?.updateSnapCollectionView()
        }
    }
    
    // MARK: - 체크리스트 관련 요소 제약조건
    private func setupChecklistView() {
        // Add managementTitle to the view
        view.addSubview(managementTitle)
        
        checklistTableViewController.viewModel = viewModel
        
        addChild(checklistTableViewController)
        view.addSubview(checklistTableViewController.view)
        checklistTableViewController.didMove(toParent: self)
        
        checklistTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        managementTitle.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout for managementTitle
        
        NSLayoutConstraint.activate([
            // 관리 목록 타이틀 제약 조건
            managementTitle.topAnchor.constraint(equalTo: snapCollectionView.bottomAnchor, constant: view.bounds.height * 0.02),
            managementTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.05),
            managementTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.05),
            
            // 체크리스트 테이블 제약 조건
            checklistTableViewController.view.topAnchor.constraint(equalTo: managementTitle.bottomAnchor, constant: view.bounds.height * 0.02),
            checklistTableViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.05),
            checklistTableViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.05),
            checklistTableViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        checklistTableViewController.tableView.register(ChecklistTableViewCell.self, forCellReuseIdentifier: "ChecklistCell")
    }
    
    // MARK: UITableViewDataSource - Number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.checklistItems.count
    }
    
    // MARK: UITableViewDataSource - Cell Configuration
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistCell", for: indexPath) as! ChecklistTableViewCell
        let item = viewModel.checklistItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    // MARK: 날짜 선택 요소 제약조건
    private func setupdatepickerView() {
        view.addSubview(customDatePickerViewController.view)
        
        customDatePickerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customDatePickerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -20),
            customDatePickerViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            customDatePickerViewController.view.heightAnchor.constraint(equalTo: customDatePickerViewController.view.widthAnchor)
        ])
        
        customDatePickerViewController.view.layer.zPosition = 1
    }
    // MARK: - 스냅뷰 컬렉션 관련 요소 제약조건
    private func setupSnapCollectionView() {
        view.addSubview(snapTitle)
        view.addSubview(editButton)
        view.addSubview(addButton)
        view.addSubview(snapCollectionView)
        
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            snapTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.05),
            snapTitle.topAnchor.constraint(equalTo: customDatePickerViewController.view.bottomAnchor, constant: view.bounds.height * 0.01),
            snapTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.05),
            
            editButton.topAnchor.constraint(equalTo: snapTitle.topAnchor),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.05),
            
            snapCollectionView.topAnchor.constraint(equalTo: snapTitle.bottomAnchor, constant: view.bounds.height * 0.01),
            snapCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.05),
            snapCollectionView.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -view.bounds.width * 0.02),
            snapCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.20),
            
            addButton.centerYAnchor.constraint(equalTo: snapCollectionView.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.05),
            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.10),
            addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor)
        ])
        
        snapCollectionView.register(SnapCollectionViewCell.self, forCellWithReuseIdentifier: "SnapCollectionViewCell")
        
        //view.sendSubviewToBack(snapCollectionView)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.snap?.imageUrls.count ?? 0
    }
    
    // MARK: UICollectionViewDataSource - Cell Configuration
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SnapCollectionViewCell", for: indexPath) as! SnapCollectionViewCell
        
        let isFirst = indexPath.item == 0
        guard let snap = viewModel.snap else {
            return cell
        }
        
        cell.configure(with: snap, index: indexPath.item, isFirst: isFirst, isEditing: self.isEditingMode)
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(self.deleteButtonTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width * 0.95
        let width = availableWidth / 2
        return CGSize(width: width, height: width)
    }
    
    // 사진 추가
    @objc private func addButtonTapped(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "사진 선택", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "카메라", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "갤러리", style: .default, handler: { _ in
            self.showPHPicker()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    // 사진 편집
    @objc private func editButtonTapped() {
        isEditingMode.toggle()
        
        if isEditingMode {
            // 편집 모드로 전환
            editButton.setTitle("완료", for: .normal)
        } else {
            // 편집 모드 종료
            editButton.setTitle("편집", for: .normal)
        }
        
        updateVisibleCellsForEditingMode(isEditingMode)
    }
    
    // 모드 전환 시 셀 업데이트
    private func updateVisibleCellsForEditingMode(_ isEditing: Bool) {
        let totalItems = snapCollectionView.numberOfItems(inSection: 0)  // 섹션이 하나이므로 0으로 고정
        for item in 0..<totalItems {
            let indexPath = IndexPath(item: item, section: 0)
            if let snapCell = snapCollectionView.cellForItem(at: indexPath) as? SnapCollectionViewCell {
                snapCell.setEditingMode(isEditing)
            }
        }
    }
    
    // 사진 삭제
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        
        guard let categoryId = viewModel.selectedCategoryId, let snap = viewModel.snap else {
            return // categoryId가 nil인 경우, cropImage 메서드를 종료
        }
        
        let imageUrl = snap.imageUrls[index]
        
        viewModel.deleteImage(categoryId: categoryId, snap: snap, imageUrlToDelete: imageUrl) { result in
            switch result {
            case .success:
                self.viewModel.snap?.imageUrls.remove(at: index) // 뷰모델의 snap객체에서 삭제할 사진 제거
                
                // 사진 아예 다 지워버리면 디비에서 스냅 자체를 삭제하고 nil로 초기화
                if self.viewModel.snap?.imageUrls.isEmpty == true {
                    self.viewModel.deleteSnap(categoryId: categoryId, snap: snap)
                    self.viewModel.snap = nil
                }
                
                self.snapCollectionView.performBatchUpdates({
                    self.snapCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)]) // 컬렉션뷰에서 인덱스로 삭제
                }) { _ in
                    // 삭제 후 나머지 셀들이 있다면 태그 업데이트
                    if self.viewModel.snap != nil {
                        self.updateCellTags()
                    }
                }
                print("사진 삭제 성공")
            case .failure(let error):
                print("사진 삭제 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // 사진 삭제 후 바뀐 셀들의 인덱스에 맞게 태그를 다시 설정하는 함수
    private func updateCellTags() {
        let totalItems = snapCollectionView.numberOfItems(inSection: 0)  // 섹션이 하나이므로 0번째 섹션 사용
        for item in 0..<totalItems {
            let indexPath = IndexPath(item: item, section: 0)
            if let snapCell = snapCollectionView.cellForItem(at: indexPath) as? SnapCollectionViewCell {
                snapCell.deleteButton.tag = item
                
                let isFirst = (item == 0)
                if isFirst {
                    snapCell.contentView.layer.borderWidth = 3
                    snapCell.contentView.layer.borderColor = UIColor.customMainColor?.cgColor
                } else {
                    snapCell.contentView.layer.borderWidth = 0
                    snapCell.contentView.layer.borderColor = nil
                }
            }
        }
    }
    
    // 사용안함
    private func presentImageCropper(with asset: PHAsset?) {
        guard let image = selectedImage, let asset = asset else { return }
        
        let cropViewController = CropViewController(viewModel: viewModel, navigationBarViewModel: navigationBarViewModel as! CustomNavigationBarViewModel) // navigationBarViewModel 전달
        cropViewController.asset = asset
        cropViewController.modalPresentationStyle = .fullScreen
        
        cropViewController.didGetCroppedImage = { [weak self] (snap: Snap) in
            self?.viewModel.snap = snap
//            self?.viewModel.snapData.append(snap) // Snap 객체를 viewModel에 추가
            self?.snapCollectionView.reloadData() // SnapCollectionView를 업데이트
        }
        
        present(cropViewController, animated: true, completion: nil)
    }
    
    private func updateUIWithCategories() {
        // 카테고리 목록을 UI에 반영하는 로직을 추가합니다.
        print("Loaded categories: \(navigationBarViewModel.categories)")
    }

    @objc private func showDatePicker() {
        customDatePickerViewController.modalPresentationStyle = .overFullScreen // Optional: to present over the current view
        customDatePickerViewController.view.backgroundColor = UIColor.clear // 배경색 설정
        present(customDatePickerViewController, animated: true, completion: nil)
    }
}

extension HomeViewController: PHPickerViewControllerDelegate {
    
    // MARK: - PHPickerViewControllerDelegate
    func showPHPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 0
        config.selection = .ordered
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    
    private func processSelectedImages() {
        let group = DispatchGroup()
        var imagesDict = [String: UIImage]()
        
        for (identifier, result) in selections {
            group.enter()
            
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    guard let image = image as? UIImage else { return }
                    imagesDict[identifier] = image
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            var images: [UIImage] = []
            
            for identifier in selectedAssetIdentifiers {
                guard let image = imagesDict[identifier] else { return }
                images.append(image)
            }
            
            guard let categoryId = UserDefaults.standard.string(forKey: "currentCategoryId") else {
                return // categoryId가 nil인 경우, cropImage 메서드를 종료
            }
            
            if let snap = viewModel.snap {
                self.viewModel.updateSnap(categoryId: categoryId, snap: snap, newImages: images) { result in
                    switch result {
                    case .success(let updatedSnap):
                        print("Snap 업데이트 성공")
                        let previousCount = self.viewModel.snap?.imageUrls.count ?? 0
                        self.viewModel.snap = updatedSnap
                        let newCount = updatedSnap.imageUrls.count

                        let newIndexPaths = (previousCount..<newCount).map {
                            IndexPath(item: $0, section: 0)
                        }
                        
                        self.snapCollectionView.performBatchUpdates({
                            self.snapCollectionView.insertItems(at: newIndexPaths)
                        }, completion: nil)
                        
                    case .failure(let error):
                        print("Snap 업데이트 실패: \(error.localizedDescription)")
                    }
                }
            } else {
                self.viewModel.saveSnap(categoryId: categoryId, images: images, createdAt: customDatePickerViewController.selectedDate) { result in
                    switch result {
                    case .success(let snap):
                        print("Snap 저장 성공")
                        self.viewModel.snap = snap
                        
                        self.viewModel.loadSnap(categoryId: categoryId, snapDate: snap.createdAt ?? Date()) { [weak self] in
                            self?.updateSnapCollectionView()
                        }
                    case .failure(let error):
                        print("Snap 저장 실패: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard !results.isEmpty else {
            print("Snap 저장 취소")
            return
        }
        
        var newSelections = [String: PHPickerResult]()
        
        for result in results {
            let identifier = result.assetIdentifier!
            newSelections[identifier] = selections[identifier] ?? result
        }
        
        selections = newSelections
        selectedAssetIdentifiers = results.compactMap { $0.assetIdentifier }
        
        if !selections.isEmpty {
            processSelectedImages()
        }
    }
}

extension HomeViewController: UIImagePickerControllerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate
    @objc func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { (success, error) in
                if success {
                    print("Image saved successfully to Photos")
                    DispatchQueue.main.async {
                        self.showPHPicker()  // PHPickerViewController 다시 띄우기
                    }
                } else if let error = error {
                    print("Error saving image: \(error)")
                }
            })
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}


#if DEBUG
struct HomeViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let navigationViewModel = CustomNavigationBarViewModel() // 기존 인스턴스 생성
        let homeVC = HomeViewController(navigationBarViewModel: navigationViewModel)
        let navController = UINavigationController(rootViewController: homeVC)
        return navController.toPreview()
    }
}
#endif
