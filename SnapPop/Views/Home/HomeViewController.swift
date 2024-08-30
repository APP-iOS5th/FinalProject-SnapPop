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

class HomeViewController:
    UIViewController,
    UINavigationControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDragDelegate,
    UICollectionViewDropDelegate{
    
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
    
    /// DatePicker UI 요소
    private let datePickerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    /// DatePicker UI 컨트롤
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ko_KR")
        picker.backgroundColor = .clear
        return picker
    }()
    /// DatePicker  캘린더 이미지 UI 컨트롤
    private let calendarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "CalenderIcon")
        imageView.tintColor = .black
        return imageView
    }()
    /// DatePicker 알림 레이블
     private let dateAlertLabel: UILabel = {
         let label = UILabel()
         label.text = " "
         label.textColor = .black
         label.backgroundColor = UIColor.customButtonColor
         label.textAlignment = .center
         label.layer.cornerRadius = 10
         label.clipsToBounds = true
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
     }()
    
    // 스냅 타이틀
    private let snapTitle: UILabel = {
        let label = UILabel()
        label.text = "Snap Pop"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // 편집 버튼 bool
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
    // 스냅 추가 안내문구
    private let noImageLabel: UILabel = {
        let label = UILabel()
        label.text = "사진을 추가해보세요!"
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Add a property to hold the cancellables
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .categoryDidChange, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.customBackgroundColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(categoryDidChange(_:)), name: .categoryDidChange, object: nil)
        
        setupBindings()
        setupDatePickerView()
        setupSnapCollectionView()
        setupChecklistView()
        updateDateAlertLabel()
        
        
        snapCollectionView.dataSource = self
        snapCollectionView.delegate = self
        
        viewModel.selectedSource = { [weak self] sourceType in
            guard let self = self else { return }
            self.viewModel.handleImageSource(sourceType, from: self)
        }
        
        // 카테고리 로드
        navigationBarViewModel.loadCategories { [weak self] in
            // 카테고리 로드 후 UI 업데이트
            self?.updateUIWithCategories()
        }
        
        if let currentCategoryId = UserDefaults.standard.string(forKey: "currentCategoryId") {
            viewModel.loadSnap(categoryId: currentCategoryId, snapDate: viewModel.selectedDate) { [weak self] in
                self?.updateSnapCollectionView()
            }
        }

        // Set the drag and drop delegates
        snapCollectionView.dragDelegate = self
        snapCollectionView.dropDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let categoryId = UserDefaults.standard.string(forKey: "currentCategoryId") {
            viewModel.loadSnap(categoryId: categoryId, snapDate: viewModel.selectedDate) { [weak self] in
                self?.updateSnapCollectionView()
            }
        }
    }
    
    func setupBindings() {
        viewModel.updateSnapCollectionView = { [weak self] in
            self?.updateSnapCollectionView()
        }
    }
    
    // 스냅 업데이트 및 UI 리로드
    func updateSnapCollectionView() {
        if let snap = viewModel.snap, !snap.imageUrls.isEmpty {
            snapCollectionView.isHidden = false
            noImageLabel.isHidden = true
            editButton.isHidden = false
        } else {
            snapCollectionView.isHidden = true
            noImageLabel.isHidden = false
            editButton.isHidden = true
        }
        
        DispatchQueue.main.async {
            self.snapCollectionView.reloadData() // UI 업데이트
        }
    }
    
    @objc private func categoryDidChange(_ notification: Notification) {
        if let userInfo = notification.userInfo, let categoryId = userInfo["categoryId"] as? String {
            viewModel.categoryDidChange(to: categoryId)
        } else {
            viewModel.categoryDidChange(to: nil)
        }
        
        // 카테고리 변경 시 snapCollectionView 리로드
        updateSnapCollectionView()
    }
    
    private func updateUIWithCategories() {
        // 카테고리 목록을 UI에 반영하는 로직을 추가합니다.
        print("Loaded categories: \(navigationBarViewModel.categories)")
    }
    /// 날짜 선택 DatePicker UI 설정
    private func setupDatePickerView() {
        view.addSubview(datePickerContainer)
        datePickerContainer.addSubview(calendarImageView)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        datePickerContainer.addSubview(datePicker)
        view.addSubview(dateAlertLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // datePickerContainer constraints
            datePickerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.05),
            datePickerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height * 0.02),
            datePickerContainer.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05),
            
            // calendarImageView constraints
            calendarImageView.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor, constant: view.bounds.width * 0.02),
            calendarImageView.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor),
            calendarImageView.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.06),
            calendarImageView.heightAnchor.constraint(equalToConstant: view.bounds.width * 0.06),
            
            // datePicker constraints
            datePicker.leadingAnchor.constraint(equalTo: calendarImageView.trailingAnchor, constant: view.bounds.width * 0.02),
            datePicker.trailingAnchor.constraint(equalTo: datePickerContainer.trailingAnchor, constant: -view.bounds.width * 0.02),
            datePicker.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor),
            
            // dateAlertLabel constraints
            dateAlertLabel.leadingAnchor.constraint(equalTo: datePicker.trailingAnchor, constant: 10),
            dateAlertLabel.trailingAnchor.constraint(equalTo: dateAlertLabel.leadingAnchor, constant: 40),
            dateAlertLabel.heightAnchor.constraint(equalTo: datePicker.heightAnchor),
            dateAlertLabel.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor)
        ])
    }
    /// 날짜 변경 시 호출
    @objc private func dateChanged(_ sender: UIDatePicker) {
        viewModel.dateChanged(sender)
        
        if let categoryId = UserDefaults.standard.string(forKey: "currentCategoryId") {
            viewModel.loadSnap(categoryId: categoryId, snapDate: viewModel.selectedDate) { [weak self] in
                self?.updateSnapCollectionView()
            }
        }
        
        updateDateAlertLabel() // 날짜 텍스트 업데이트
        self.dismiss(animated: false, completion: nil) // UIDatePicker 닫기
    }
    /// 날짜 알림 버튼 텍스트 업데이트
    private func updateDateAlertLabel() {
        let selectedDate = datePicker.date
        let currentDate = Date()
        
        let calendar = Calendar.current
        let selectedDay = calendar.startOfDay(for: selectedDate)
        let today = calendar.startOfDay(for: currentDate)
        
        // Calculate day difference
        let dayDifference = calendar.dateComponents([.day], from: today, to: selectedDay).day ?? 0
        
        dateAlertLabel.isHidden = false
        
        switch dayDifference {
        case 0:
            dateAlertLabel.text = "오늘"
        case -1:
            dateAlertLabel.text = "어제"
        case 1:
            dateAlertLabel.text = "내일"
        case 2:
            dateAlertLabel.text = "모레"
        default:
            dateAlertLabel.text = ""
            dateAlertLabel.isHidden = true
        }
    }
    /// 체크리스트 관련 요소 제약조건
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
    /// 체크리스트( UITableViewDataSource - Number of Rows)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.checklistItems.count
    }
    /// 체크리스트(UITableViewDataSource - Cell Configuration)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistCell", for: indexPath) as! ChecklistTableViewCell
        let item = viewModel.checklistItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    /// 스냅뷰 컬렉션 관련 요소 제약조건
    private func setupSnapCollectionView() {
        view.addSubview(snapTitle)
        view.addSubview(editButton)
        view.addSubview(addButton)
        view.addSubview(snapCollectionView)
        
        view.addSubview(noImageLabel)
        
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            snapTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.05),
            snapTitle.topAnchor.constraint(equalTo: datePickerContainer.bottomAnchor, constant: view.bounds.height * 0.01),
            snapTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.05),
            
            editButton.topAnchor.constraint(equalTo: snapTitle.topAnchor),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.05),
            
            noImageLabel.topAnchor.constraint(equalTo: snapTitle.bottomAnchor, constant: view.bounds.height * 0.08),
            noImageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor), // 중앙 정렬
            
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
        snapCollectionView.bringSubviewToFront(noImageLabel)
        // 초기 상태 설정
        snapCollectionView.isHidden = true
        noImageLabel.isHidden = false
    }
    /// 스냅뷰 (UICollectionViewDataSource)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.snap?.imageUrls.count ?? 0
    }
    ///스냅뷰 ( UICollectionViewDataSource - Cell Configuration)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SnapCollectionViewCell", for: indexPath) as! SnapCollectionViewCell
        let isFirst = indexPath.item == 0
        guard let snap = viewModel.snap else {
            // 스냅이 없을 경우 셀 초기화 및 문구, 아이콘 표시
            cell.prepareForReuse() // 셀 초기화
            noImageLabel.isHidden = false // 스냅이 없으면 문구 표시
            return cell
        }
        
        // 스냅이 있을 경우 셀 구성
        cell.configure(with: snap, index: indexPath.item, isFirst: isFirst, isEditing: self.isEditingMode)
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(self.deleteButtonTapped(_:)), for: .touchUpInside)
        cell.currentIndex = indexPath.item
        cell.imageUrls = snap.imageUrls
        
        // 스냅이 있을 경우 문구와 아이콘 숨김
        noImageLabel.isHidden = true
        return cell
    }
    ///스냅뷰 (UICollectionViewDelegateFlowLayout)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width * 0.95
        let width = availableWidth / 2
        return CGSize(width: width, height: width)
    }
    
    /// 스냅 사진 추가
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
    /// 스냅 사진 편집
    @objc private func editButtonTapped() {
        isEditingMode.toggle()
        
        if isEditingMode {
            // 편집 모드로 전환
            editButton.setTitle("완료", for: .normal)
            snapCollectionView.isScrollEnabled = false // 스크롤 비활성화
        } else {
            // 편집 모드 종료
            editButton.setTitle("편집", for: .normal)
            snapCollectionView.isScrollEnabled = true // 스크롤 활성화
        }
        
        updateVisibleCellsForEditingMode(isEditingMode)
    }
    /// 스냅 편집  모드 전환 시 셀 업데이트
    private func updateVisibleCellsForEditingMode(_ isEditing: Bool) {
        let totalItems = snapCollectionView.numberOfItems(inSection: 0)  // 섹션이 하나이므로 0으로 고정
        for item in 0..<totalItems {
            let indexPath = IndexPath(item: item, section: 0)
            if let snapCell = snapCollectionView.cellForItem(at: indexPath) as? SnapCollectionViewCell {
                snapCell.setEditingMode(isEditing)
            }
        }
    }
    /// 스냅 사진 삭제
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        
        guard let categoryId = viewModel.selectedCategoryId, let snap = viewModel.snap else {
            return // categoryId가 nil인 경우, cropImage 메서드를 종료
        }
        
        let imageUrl = snap.imageUrls[index]
        
        viewModel.deleteImage(categoryId: categoryId, snap: snap, imageUrlToDelete: imageUrl) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.viewModel.snap?.imageUrls.remove(at: index) // 뷰모델의 snap객체에서 삭제할 사진 제거
                    
                    // 사진 아예 다 지워버리면 디비에서 스냅 자체를 삭제하고 nil로 초기화
                    if self.viewModel.snap?.imageUrls.isEmpty == true {
                        self.viewModel.deleteSnap(categoryId: categoryId, snap: snap)
                        self.viewModel.snap = nil
                        self.updateSnapCollectionView()
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
    }
    /// 스냅 사진 삭제 후 바뀐 셀들의 인덱스에 맞게 태그를 다시 설정하는 함수
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
    // MARK: - UICollectionViewDragDelegate
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard isEditingMode else { return [] } // 편집 모드가 아닐 경우 빈 배열 반환

        let item = viewModel.snap?.imageUrls[indexPath.item]
        let itemProvider = NSItemProvider(object: item as! NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    // MARK: - UICollectionViewDropDelegate
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return isEditingMode && session.canLoadObjects(ofClass: NSString.self) // 편집 모드일 때만 드롭 가능
    }
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard isEditingMode else { return } // 편집 모드가 아닐 경우 아무 작업도 하지 않음
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        guard let categoryId = viewModel.selectedCategoryId, let snap = viewModel.snap else { return }

        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                let sourceIndex = sourceIndexPath.item
                let destinationIndex = destinationIndexPath.item

                // Snap 데이터 업데이트 및 UICollectionView의 아이템 이동
                updateSnapAndMoveItem(collectionView: collectionView, from: sourceIndex, to: destinationIndex, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
            }
        }
    }
    func updateSnapAndMoveItem(collectionView: UICollectionView, from sourceIndex: Int, to destinationIndex: Int, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        guard sourceIndex != destinationIndex, sourceIndex < viewModel.snap?.imageUrls.count ?? 0 else { return }

        // Snap 데이터 업데이트
        let itemToMove = viewModel.snap?.imageUrls[sourceIndex]
        viewModel.snap?.imageUrls.remove(at: sourceIndex)
        if destinationIndex >= (viewModel.snap?.imageUrls.count ?? 0) {
            viewModel.snap?.imageUrls.append(itemToMove!)
        } else {
            viewModel.snap?.imageUrls.insert(itemToMove!, at: destinationIndex)
        }
        print("Item moved from index \(sourceIndex) to \(destinationIndex)")
        print("Updated imageUrls: \(viewModel.snap?.imageUrls ?? [])")

        // CollectionView에서 아이템 이동
        collectionView.performBatchUpdates({
            collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
        }, completion: { _ in
            // Update the snap instead of saving
            self.viewModel.updateSnap(categoryId: self.viewModel.selectedCategoryId!, snap: self.viewModel.snap!, newImages: self.viewModel.snap?.imageUrls.compactMap { UIImage(named: $0) } ?? []) { result in
                switch result {
                case .success(let updatedSnap):
                    self.viewModel.snap = updatedSnap
                    print("Snap updated successfully.")
                    // 즉시 UI 업데이트
                    self.updateSnapCollectionView() // UI를 즉시 업데이트
                case .failure(let error):
                    print("Error updating snap: \(error.localizedDescription)")
                }
            }
        })
    }
    func didTapSnapCell(with imageUrls: [String], currentIndex: Int) {
        let expandVC = SnapExpandSheetViewController(imageUrls: imageUrls, currentIndex: currentIndex) // ViewController 초기화
        expandVC.modalPresentationStyle = .pageSheet // 모달 시트로 표시
        present(expandVC, animated: true, completion: nil) // ViewController 표시
    }
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 선택된 스냅 데이터 가져오기
        guard let snap = viewModel.snap, indexPath.item < snap.imageUrls.count else {
            print("Invalid index or snap data.")
            return
        }
        
        // SnapExpandSheetViewController 초기화
        let expandVC = SnapExpandSheetViewController(imageUrls: snap.imageUrls, currentIndex: indexPath.item) // ViewController 초기화
        expandVC.modalPresentationStyle = .pageSheet // 모달 시트로 표시
        
        // sheetPresentationController 설정
        if let sheet = expandVC.sheetPresentationController {
            sheet.detents = [.medium()] // 모달 크기 설정
            sheet.prefersGrabberVisible = true // 그랩바 표시
        }
        
        // 모달 표시
        present(expandVC, animated: true, completion: nil)
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
            
            guard let categoryId = viewModel.selectedCategoryId else { return }
            
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
                self.viewModel.saveSnap(categoryId: categoryId, images: images, createdAt: datePicker.date) { result in
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
