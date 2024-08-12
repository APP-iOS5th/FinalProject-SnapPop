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

class HomeViewController: NavigationViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    // ViewModel
    private var viewModel = HomeViewModel()
    
    // UI 요소
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 250/255, green: 251/255, blue: 253/255, alpha: 1.0)
        setupDatePickerView()
        setupSnapCollectionConstraints()

        snapcollectionView.dragDelegate = self
        snapcollectionView.dropDelegate = self
        
        // UICollectionView 설정
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SnapCollectionViewCell", for: indexPath) as! SnapCollectionViewCell
        
        let image = viewModel.tempimagedata[indexPath.item]
        cell.snapimageView.image = image
        
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
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        for item in coordinator.items {
            let sourceIndexPath = item.sourceIndexPath
            
            if let sourceIndexPath = sourceIndexPath {
                let imageToMove = viewModel.tempimagedata.remove(at: sourceIndexPath.item)
                viewModel.tempimagedata.insert(imageToMove, at: destinationIndexPath.item)
                
                collectionView.performBatchUpdates({
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                }, completion: nil)
            }
        }
    }
    // MARK: 사진 추가버튼 이벤트 메소드 (카메라or갤러리를 선택하라는 alertcontroller show)
    @objc private func addButtonTapped() {
        let alertController = UIAlertController(title: "사진 추가", message: "사진을 추가할 방법을 선택하세요.", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "카메라", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            }
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "갤러리", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .photoLibrary)
            }
            alertController.addAction(photoLibraryAction)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - 사진 접근 이미지 피커 표시 메서드
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        viewModel.requestPhotoLibraryPermission { [weak self] granted in
            guard granted else {
                let alert = UIAlertController(title: "권한 필요", message: "사진 접근 권한이 필요합니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                return
            }
            
            // 이미지 피커 컨트롤러를 표시합니다.
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = sourceType
            imagePickerController.delegate = self
            imagePickerController.mediaTypes = [kUTTypeImage as String]
            
            self?.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                self.viewModel.addImage(image)
                self.snapcollectionView.reloadData()
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
