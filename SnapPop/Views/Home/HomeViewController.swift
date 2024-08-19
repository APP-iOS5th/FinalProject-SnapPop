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

class HomeViewController: NavigationViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDragDelegate,
    UICollectionViewDropDelegate {
    
    // ViewModel
    private var viewModel = HomeViewModel()
    
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
        button.backgroundColor = UIColor(red: 92/255, green: 223/255, blue: 231/255, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 250/255, green: 251/255, blue: 253/255, alpha: 1.0)
        setupDatePickerView()
        setupSnapCollectionView()
        setupChecklistView()
        
        viewModel.tempSnapData = Snap.sampleData()
        snapCollectionView.dataSource = self
        snapCollectionView.delegate = self
        snapCollectionView.dragDelegate = self
        snapCollectionView.dropDelegate = self
        
        viewModel.selectedSource = { [weak self] sourceType in
            guard let self = self else { return }
            self.viewModel.handleImageSource(sourceType, from: self)
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
        datePickerContainer.backgroundColor = UIColor(red: 199/255, green: 239/255, blue: 247/255, alpha: 1.0)
        datePickerContainer.layer.cornerRadius = 10
        datePickerContainer.layer.masksToBounds = true
        view.addSubview(datePickerContainer)
    }
    
    // MARK: 날짜 캘린더 이미지 UI 컨트롤
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
            datePickerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePickerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            datePickerContainer.heightAnchor.constraint(equalToConstant: 40),
            
            calendarImageView.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor, constant: 8),
            calendarImageView.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor),
            calendarImageView.widthAnchor.constraint(equalToConstant: 24),
            calendarImageView.heightAnchor.constraint(equalToConstant: 24),
            
            datePicker.leadingAnchor.constraint(equalTo: calendarImageView.trailingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: datePickerContainer.trailingAnchor, constant: -8),
            datePicker.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor)
        ])
    }
    
    // MARK: - 날짜 변경 시 호출
    @objc private func dateChanged(_ sender: UIDatePicker) {
        viewModel.dateChanged(sender)
    }
    
    // MARK: - 체크리스트 관련 요소 제약조건
    private func setupChecklistView() {
        checklistTableViewController.viewModel = viewModel
        
        addChild(checklistTableViewController)
        view.addSubview(checklistTableViewController.view)
        checklistTableViewController.didMove(toParent: self)
        
        checklistTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checklistTableViewController.view.topAnchor.constraint(equalTo: snapCollectionView.bottomAnchor, constant: 20),
            checklistTableViewController.view.leadingAnchor.constraint(equalTo: snapCollectionView.leadingAnchor),
            checklistTableViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            checklistTableViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
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
        
        // Edit button constraints
        NSLayoutConstraint.activate([
            snapTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            snapTitle.topAnchor.constraint(equalTo: datePickerContainer.bottomAnchor, constant: 20),
            
            editButton.topAnchor.constraint(equalTo: snapTitle.topAnchor),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        // Snap collection view constraints
        NSLayoutConstraint.activate([
            snapCollectionView.topAnchor.constraint(equalTo: snapTitle.bottomAnchor, constant: 20),
            snapCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            snapCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80), // 여백을 추가
            snapCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
        ])
        
        // Add button constraints
        NSLayoutConstraint.activate([
            addButton.centerYAnchor.constraint(equalTo: snapCollectionView.centerYAnchor),
            addButton.leadingAnchor.constraint(equalTo: snapCollectionView.trailingAnchor, constant: 10),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
            addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor)
        ])
        
        snapCollectionView.dragInteractionEnabled = true
        snapCollectionView.register(SnapCollectionViewCell.self, forCellWithReuseIdentifier: "SnapCollectionViewCell")
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.tempSnapData.count
    }
    
    // MARK: UICollectionViewDataSource - Cell Configuration
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SnapCollectionViewCell", for: indexPath) as! SnapCollectionViewCell
        let snap = viewModel.tempSnapData[indexPath.item]
        let isFirst = indexPath.item == 0
        
        cell.configure(with: snap, isFirst: isFirst, isEditing: isEditingMode)
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width * 0.95 // 전체 너비의 95%만 사용
        let width = availableWidth / 2
        return CGSize(width: width, height: width)
    }
    
    // MARK: - UICollectionViewDragDelegate
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let snap = viewModel.tempSnapData[indexPath.item]
        let itemProvider = NSItemProvider(object: snap.id! as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = snap
        return [dragItem]
    }
    
    // MARK: - UICollectionViewDropDelegate
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row, section: 0)
        }
        
        if coordinator.proposal.operation == .move {
            reloadItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
    }
    
    private func reloadItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        guard let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath else { return }
        
        viewModel.droptoSnapUpdate(from: sourceIndexPath.item, to: destinationIndexPath.item)
        
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
        }, completion: { _ in
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    // MARK: - 사진 추가버튼 이벤트 메소드
    @objc private func addButtonTapped() {
        viewModel.showImagePickerActionSheet(from: self)
    }

    @objc private func editButtonTapped() {
        
        isEditingMode.toggle()
            
            if isEditingMode {
                // 편집 모드로 전환
                editButton.setTitle("완료", for: .normal)
            } else {
                // 편집 모드 종료, 데이터 저장
                viewModel.saveEditedData()
                editButton.setTitle("편집", for: .normal)
            }
            
            snapCollectionView.reloadData() // 데이터 변경 반영
//        
//        isEditingMode.toggle()
//        editButton.setTitle(isEditingMode ? "완료" : "편집", for: .normal)
//        snapCollectionView.reloadData()
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        viewModel.deleteSnap(at: index)
        snapCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let imageURL = info[.imageURL] as? URL {
            viewModel.fetchPhotoDetails(from: imageURL) { success in
                if success {
                    print("사진 로드 성공")
                } else {
                    print("사진 로드 실패")
                }
            }
        }
    }
}

#if DEBUG
struct HomeViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let homeVC = HomeViewController()
        let navController = UINavigationController(rootViewController: homeVC)
        return navController.toPreview()
    }
}
#endif
