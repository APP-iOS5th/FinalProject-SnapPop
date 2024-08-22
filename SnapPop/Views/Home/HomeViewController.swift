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
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout, PHPickerViewControllerDelegate {
    
    // ViewModel
    private var viewModel = HomeViewModel(snapService: SnapService())
    var navigationBarViewModel: CustomNavigationBarViewModelProtocol // 프로퍼티로 선언
    
    // 초기화 메서드 추가
    init(navigationBarViewModel: CustomNavigationBarViewModelProtocol) {
        self.navigationBarViewModel = navigationBarViewModel
        super.init(nibName: nil, bundle: nil) // 부모 클래스 초기화
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 스토리보드 사용 시 필요
    }
    
    // DatePicker UI 요소
    private let datePickerContainer = UIView()
    private let datePicker = UIDatePicker()
    private let calendarImageView = UIImageView()
    
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
        setupDatePickerView()
        setupSnapCollectionView()
        setupChecklistView()
        
        snapCollectionView.dataSource = self
        snapCollectionView.delegate = self
        
        viewModel.selectedSource = { [weak self] sourceType in
            guard let self = self else { return }
            self.viewModel.handleImageSource(sourceType, from: self)
        }
        
        // 스냅 데이터가 변경될 때 UI 업데이트
        viewModel.$snapData.sink { [weak self] _ in
            self?.snapCollectionView.reloadData() // UI 업데이트
        }.store(in: &cancellables)
        
        // 카테고리 로드
        navigationBarViewModel.loadCategories { [weak self] in
            // 카테고리 로드 후 UI 업데이트
            self?.updateUIWithCategories()
        }
        
        viewModel.loadSnap(categoryId: "nhY7XXG7lm7gy7eUgLxi", snapDate: Date())
    }
    
    @objc private func updateSnapCollectionView() {
        DispatchQueue.main.async {
            self.snapCollectionView.reloadData() // UI 업데이트
        }
    }
    
    // MARK: - 날짜 선택 DatePicker UI 설정
    private func setupDatePickerView() {
        setupDatePickerContainer()
        setupCalendarImageView()
        setupDatePicker()
        setupDatePickerConstraints()
    }
    
    // MARK: 날짜 선택 UI 컨트롤
    private func setupDatePickerContainer() {
        datePickerContainer.translatesAutoresizingMaskIntoConstraints = false
        datePickerContainer.backgroundColor = UIColor.customButtonColor
        datePickerContainer.layer.cornerRadius = 10
        datePickerContainer.layer.masksToBounds = true
        view.addSubview(datePickerContainer)
    }
    
    // MARK: 날 캘린더 이미지 UI 컨트롤
    private func setupCalendarImageView() {
        calendarImageView.image = UIImage(named: "CalenderIcon")
        calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        calendarImageView.tintColor = .black
        datePickerContainer.addSubview(calendarImageView)
    }
    
    // MARK: 날짜 선택기 UI 컨트롤
    private func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.backgroundColor = .clear
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        datePickerContainer.addSubview(datePicker)
    }
    
    // MARK: 날짜 선택기 제약 조건 설정
    private func setupDatePickerConstraints() {
        NSLayoutConstraint.activate([
            datePickerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.05),
            datePickerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height * 0.02),
            datePickerContainer.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05),
            
            calendarImageView.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor, constant: view.bounds.width * 0.02),
            calendarImageView.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor),
            calendarImageView.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.06),
            calendarImageView.heightAnchor.constraint(equalToConstant: view.bounds.width * 0.06),
            
            datePicker.leadingAnchor.constraint(equalTo: calendarImageView.trailingAnchor, constant: view.bounds.width * 0.02),
            datePicker.trailingAnchor.constraint(equalTo: datePickerContainer.trailingAnchor, constant: -view.bounds.width * 0.02),
            datePicker.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor)
        ])
    }
    
    // MARK: - 날짜 변경 시 호출
    @objc private func dateChanged(_ sender: UIDatePicker) {
        viewModel.dateChanged(sender)
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
            snapTitle.topAnchor.constraint(equalTo: datePickerContainer.bottomAnchor, constant: view.bounds.height * 0.01),
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
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.snap.imageUrls.count
    }
    
    // MARK: UICollectionViewDataSource - Cell Configuration
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SnapCollectionViewCell", for: indexPath) as! SnapCollectionViewCell
        
        let isFirst = indexPath.item == 0
        
        cell.configure(with: viewModel.snap, index: indexPath.item, isFirst: isFirst, isEditing: self.isEditingMode)
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(self.deleteButtonTapped(_:)), for: .touchUpInside)
        return cell
//        let snap =
//        let isFirst = indexPath.item == 0
//        
//        cell.configure(with: snap, isFirst: isFirst, isEditing: isEditingMode)
//        cell.deleteButton.tag = indexPath.item
//        cell.deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
//        
//        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width * 0.95
        let width = availableWidth / 2
        return CGSize(width: width, height: width)
    }
    
    @objc private func editButtonTapped() {
        isEditingMode.toggle()
        
        if isEditingMode {
            // 편집 모드로 전환
            editButton.setTitle("완료", for: .normal)
        } else {
            // 편집 모드 종료, 데이터 저장
            //viewModel.saveSnapsToFirebase()
            editButton.setTitle("편집", for: .normal)
        }
        
        snapCollectionView.reloadData() // 데이터 변경 반영
    }
    
    @objc private func addButtonTapped(_ sender: UIButton) {
//        viewModel.showImagePickerActionSheet(from: self)
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
    
    func showPHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    
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
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        //viewModel.deleteSnap(at: index)
        //snapCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true, completion: nil)
//        
//        if let image = info[.originalImage] as? UIImage {
//            self.selectedImage = image
////            self.presentImageCropper(with: info[.phAsset] as? PHAsset)
//            print("사진 로드 성공")
//        } else {
//            print("사진 로드 실패")
//        }
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
    
    // PHPickerViewControllerDelegate method
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var images: [UIImage] = []
        let group = DispatchGroup()
        
        picker.dismiss(animated: true, completion: nil)
        
        guard !results.isEmpty else {
            print("Snap 저장 취소")
            return
        }
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    DispatchQueue.main.async {
                        guard let self = self, let image = image as? UIImage else { return }
                        images.append(image)
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            guard let categoryId = UserDefaults.standard.string(forKey: "currentCategoryId") else {
                return // categoryId가 nil인 경우, cropImage 메서드를 종료
            }
            
            self.viewModel.saveSnap(images: images, categoryId: categoryId) { result in
                switch result {
                case .success(let snap):
                    print("Snap 저장 성공")
                    self.viewModel.snapData = snap
                    DispatchQueue.main.async {
                        self.snapCollectionView.reloadData()
                    }
                case .failure(let error):
                    print("Snap 저장 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func presentImageCropper(with asset: PHAsset?) {
        guard let image = selectedImage, let asset = asset else { return }
        
        let cropViewController = CropViewController(viewModel: viewModel, navigationBarViewModel: navigationBarViewModel as! CustomNavigationBarViewModel) // navigationBarViewModel 전달
        cropViewController.asset = asset
        cropViewController.modalPresentationStyle = .fullScreen
        
        cropViewController.didGetCroppedImage = { [weak self] (snap: Snap) in
            self?.viewModel.snapData = snap
//            self?.viewModel.snapData.append(snap) // Snap 객체를 viewModel에 추가
            self?.snapCollectionView.reloadData() // SnapCollectionView를 업데이트
        }
        
        present(cropViewController, animated: true, completion: nil)
    }
    
    private func updateUIWithCategories() {
        // 카테고리 목록을 UI에 반영하는 로직을 추가합니다.
        print("Loaded categories: \(navigationBarViewModel.categories)")
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
