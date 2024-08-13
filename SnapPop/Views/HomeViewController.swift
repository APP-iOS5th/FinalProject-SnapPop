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
    private let snapcollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let snapcollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        snapcollectionView.backgroundColor = .clear
        snapcollectionView.translatesAutoresizingMaskIntoConstraints = false
        return snapcollectionView
    }()
    
    // 체크리스트 테이블
    private let checklistTableViewController = ChecklistTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 250/255, green: 251/255, blue: 253/255, alpha: 1.0)
        setupDatePickerView()
        setupSnapCollectionConstraints()
        setupChecklistConstraints()

        snapcollectionView.dragDelegate = self
        snapcollectionView.dropDelegate = self
        snapcollectionView.dataSource = self
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
            datePicker.centerYAnchor.constraint(equalTo: datePickerContainer.centerYAnchor),
        ])
    }
    
    // MARK: - 날짜 변경 시 호출
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let selectedDate = viewModel.dateChanged(sender)
    }
    
    // MARK: - 체크리스트 관련 요소 제약조건
    private func setupChecklistConstraints() {
        checklistTableViewController.viewModel = viewModel
        
        addChild(checklistTableViewController)
        view.addSubview(checklistTableViewController.view)
        checklistTableViewController.view.frame = view.bounds
        checklistTableViewController.didMove(toParent: self)
        
        view.addSubview(checklistTableViewController.view)
        checklistTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checklistTableViewController.view.topAnchor.constraint(equalTo: snapcollectionView.bottomAnchor, constant: 20),
            checklistTableViewController.view.leadingAnchor.constraint(equalTo: snapcollectionView.leadingAnchor),
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckListCell", for: indexPath) as! ChecklistTableViewCell
        
        let item = viewModel.checklistItems[indexPath.row] ?? ChecklistItem(id: "", categoryId: "", title: "", color: "", memo: "", status: false, createdAt: Date(), repeatCycle: 0, endDate: Date())
        
        cell.configure(with: item)
        return cell
    }
    // MARK: - 스냅뷰 컬렉션 관련 요소 제약조건
    private func setupSnapCollectionConstraints() {
        view.addSubview(snapTitle)
        view.addSubview(editButton)
        view.addSubview(addButton)
        view.addSubview(snapcollectionView)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Snap Pop 제목 제약 조건
            snapTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            snapTitle.topAnchor.constraint(equalTo: datePickerContainer.bottomAnchor, constant: 20),
            
            // 편집 버튼 제약 조건
            editButton.topAnchor.constraint(equalTo: snapTitle.topAnchor),
            editButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            
            // UICollectionView 제약 조건
            snapcollectionView.topAnchor.constraint(equalTo: snapTitle.bottomAnchor, constant: 20),
            snapcollectionView.leadingAnchor.constraint(equalTo: snapTitle.leadingAnchor),
            snapcollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -70),
            snapcollectionView.heightAnchor.constraint(equalTo: snapcollectionView.widthAnchor, multiplier: 0.5),
            
            // 추가 버튼 제약 조건
            addButton.centerYAnchor.constraint(equalTo: snapcollectionView.centerYAnchor),
            addButton.leadingAnchor.constraint(equalTo: snapcollectionView.trailingAnchor, constant: 10),
            addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.1),
            addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor)
        ])
        
        snapcollectionView.dataSource = self
        snapcollectionView.delegate = self
        snapcollectionView.register(SnapCollectionViewCell.self, forCellWithReuseIdentifier: "SnapCollectionViewCell")
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.tempimagedata.count
    }
    
    // MARK: UICollectionViewDataSource - Cell Configuration
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SnapCollectionViewCell", for: indexPath) as! SnapCollectionViewCell
          
          let image = viewModel.tempimagedata[indexPath.item]
          let isFirst = indexPath.item == 0
          let isEditing = false 
          cell.configure(with: image, isFirst: isFirst, isEditing: isEditing)
          
          return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width * 0.95 // 전체 너비의 90%만 사용
        let width = availableWidth / 2
        let height = width
        return CGSize(width: width, height: height)
    }
    
    // MARK: - 스냅 사진 드래그 메서드
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let image = viewModel.tempimagedata[indexPath.item]
        let imageProvider = NSItemProvider(object: image)
        let dragItem = UIDragItem(itemProvider: imageProvider)
        dragItem.localObject = image
        return [dragItem]
    }
    
    // MARK: - 스냅 사진 드롭 메서드
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        
        guard coordinator.proposal.operation == .move else { return }
        
        // 드랍된 항목을 처리
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                collectionView.performBatchUpdates({
                    // sourceIndexPath에서 항목을 제거하고 destinationIndexPath로 삽입
                    let movedImage = viewModel.tempimagedata.remove(at: sourceIndexPath.item)
                    viewModel.tempimagedata.insert(movedImage, at: destinationIndexPath.item)
                    
                    // 컬렉션 뷰 항목 이동
                    collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
                }, completion: nil)
            }
        }
    }
    
    // MARK: 사진 추가버튼 이벤트 메소드 (카메라or갤러리를 선택하라는 alertcontroller show)
    @objc func addButtonTapped() {
        // UIAlertController 생성
        let alert = UIAlertController(title: "사진을 선택해주세요.", message: nil, preferredStyle: .actionSheet)
        
        // 카메라 버튼 추가
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default, handler: { _ in
                self.presentImagePicker(with: .camera)
            }))
        }
        
        // 갤러리 버튼 추가
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "갤러리", style: .default, handler: { _ in
                self.presentImagePicker(with: .photoLibrary)
            }))
        }
        
        // 취소 버튼 추가
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // 모달 표시
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Present Image Picker
    func presentImagePicker(with sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
           imagePickerController.delegate = self
           imagePickerController.sourceType = sourceType
           self.present(imagePickerController, animated: true, completion: nil)
       }
    }
    
    // MARK: 이미지 선택 후 처리
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            // 선택된 이미지를 처리하는 코드 작성
            print("Selected image: \(selectedImage)")
        }
        picker.dismiss(animated: true, completion: nil)
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
