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
    let datePickerContainer = UIView()
    let datePicker = UIDatePicker()
    let calendarImageView = UIImageView()
    
    // 스냅 타이틀
    let snapTitle: UILabel = {
        let label = UILabel()
        label.text = "Snap Pop"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 편집 버튼
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("편집", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 이미지 추가 버튼
    let addButton: UIButton = {
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
        self.view.backgroundColor = UIColor(red: 250/255, green: 251/255, blue: 253/255, alpha: 1.0)
        setupDatePickerView()
        setupSnapCollectionConstraints()
        setupChecklistConstraints()
        
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
        setupDatePickerConstraints() // Ensure constraints are set after adding subviews
    }
    // MARK: 날짜 선택 UI 컨트롤
    private func setupDatePickerContainer() {
        datePickerContainer.translatesAutoresizingMaskIntoConstraints = false
        datePickerContainer.backgroundColor = UIColor(red: 199/255, green: 239/255, blue: 247/255, alpha: 1.0)
        datePickerContainer.layer.cornerRadius = 10
        datePickerContainer.layer.masksToBounds = true
        self.view.addSubview(datePickerContainer)
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
        datePicker.backgroundColor = UIColor.clear
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        datePickerContainer.addSubview(datePicker)
    }
    
    // MARK: 날짜 선택기 제약 조건 설정
    private func setupDatePickerConstraints() {
        NSLayoutConstraint.activate([
            // DatePicker 컨테이너 제약 조건
            datePickerContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            datePickerContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            datePickerContainer.heightAnchor.constraint(equalToConstant: 40),
            
            // 캘린더 이미지 제약 조건
            calendarImageView.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor, constant: 8),
            calendarImageView.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor),
            calendarImageView.widthAnchor.constraint(equalToConstant: 24),
            calendarImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // DatePicker 제약 조건
            datePicker.leadingAnchor.constraint(equalTo: calendarImageView.trailingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: datePickerContainer.trailingAnchor, constant: -8),
            datePicker.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor)
        ])
    }
    
    // MARK: - 날짜 변경 시 호출
    @objc private func dateChanged(_ sender: UIDatePicker) {
        _ = viewModel.dateChanged(sender)
    }
    
    // MARK: - 체크리스트 관련 요소 제약조건
    private func setupChecklistConstraints() {
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
    private func setupSnapCollectionConstraints() {
        view.addSubview(snapTitle)
        view.addSubview(editButton)
        view.addSubview(addButton)
        view.addSubview(snapCollectionView)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Snap Pop 제목 제약 조건
            snapTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            snapTitle.topAnchor.constraint(equalTo: datePickerContainer.bottomAnchor, constant: 20),
            
            // 편집 버튼 제약 조건
            editButton.topAnchor.constraint(equalTo: snapTitle.topAnchor),
            editButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            
            // UICollectionView 제약 조건
            snapCollectionView.topAnchor.constraint(equalTo: snapTitle.bottomAnchor, constant: 20),
            snapCollectionView.leadingAnchor.constraint(equalTo: snapTitle.leadingAnchor),
            snapCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -70),
            snapCollectionView.heightAnchor.constraint(equalTo: snapCollectionView.widthAnchor, multiplier: 0.5),
            
            // 추가 버튼 제약 조건
            addButton.centerYAnchor.constraint(equalTo: snapCollectionView.centerYAnchor),
            addButton.leadingAnchor.constraint(equalTo: snapCollectionView.trailingAnchor, constant: 10),
            addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.1),
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
        let snap = viewModel.tempSnapData[indexPath.item] // 'snaps'는 Snap 객체의 배열입니다.
          
          cell.configure(with: snap, isFirst: indexPath.item == 0, isEditing: isEditing)
          return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width * 0.95 // 전체 너비의 95%만 사용
        let width = availableWidth / 2
        let height = width
        return CGSize(width: width, height: height)
    }
    
    // MARK: - UICollectionViewDragDelegate
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let snap = viewModel.tempSnapData[indexPath.item]
        let itemProvider = NSItemProvider(object: snap.id! as NSString) // ID를 사용하여 드래그 아이템을 식별
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = snap
        return [dragItem]
    }
    
    // MARK: - 스냅 사진 드롭 메서드
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        
        if coordinator.proposal.operation == .move {
            reloadItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: snapCollectionView)
        }
    }
    // MARK: - 스냅 사진 드랍 후, 스냅사진 리로딩
    private func reloadItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        guard let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath else { return }
        
        viewModel.droptoSnapUpdate(from: sourceIndexPath.item, to: destinationIndexPath.item)
        
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
        }, completion: { _ in
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        })
    }
    
    // MARK: - UICollectionView Drop Session Handling
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: any UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        
        return UICollectionViewDropProposal(operation: .forbidden)
    }

    // MARK: - 사진 추가버튼 이벤트 메소드
    @objc func addButtonTapped() {
        viewModel.imagepickerActionSheet(from: self)
        
        viewModel.selectedSource = { [weak self] sourceType in
            guard let self = self else { return }
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            DispatchQueue.main.async {
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let imageURL = info[.imageURL] as? URL {
            fetchPhotoDetails(from: imageURL)
        } else if let image = info[.originalImage] as? UIImage {
            print("선택된 이미지: \(image)")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func fetchPhotoDetails(from url: URL) {
        let assets = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
        assets.enumerateObjects { asset, _, _ in
            let creationDate = asset.creationDate ?? Date()
            let localIdentifier = asset.localIdentifier
            let imageUrl = url.absoluteString
            let snap = Snap(id: localIdentifier, imageUrls: [imageUrl], createdAt: creationDate)

            self.viewModel.tempSnapData.append(snap)
        }
        print("Found asset count: \(assets.count)")
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
