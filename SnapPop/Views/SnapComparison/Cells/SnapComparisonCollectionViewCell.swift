//
//  SnapComparisonCollectionViewCell.swift
//  SnapPop
//
//  Created by 정종원 on 8/8/24.
//

import UIKit
import Kingfisher

class SnapComparisonCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    private var viewModel: SnapComparisonCellViewModelProtocol?
    static let identifier = "SnapCollectionViewCell"
    
    // MARK: - UIComponents
    /// 스냅 날자 레이블
    lazy var snapCellDateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 날자별 스냅 콜렉션 뷰
    lazy var horizontalSnapPhotoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HorizontalSnapPhotoCollectionViewCell.self, forCellWithReuseIdentifier: HorizontalSnapPhotoCollectionViewCell.identifier)
        collectionView.backgroundColor = .dynamicBackgroundInsideColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .dynamicBackgroundInsideColor
        return collectionView
    }()
    
    // MARK: - Initializers
    
    init(viewModel: SnapComparisonCellViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func setupLayout() {
        addSubviews([
            snapCellDateLabel,
            horizontalSnapPhotoCollectionView
        ])
        
        NSLayoutConstraint.activate([
            snapCellDateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            snapCellDateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            
            horizontalSnapPhotoCollectionView.topAnchor.constraint(equalTo: snapCellDateLabel.bottomAnchor, constant: 10),
            horizontalSnapPhotoCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            horizontalSnapPhotoCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            horizontalSnapPhotoCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            horizontalSnapPhotoCollectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
    }
    
    func configure(with viewModel: SnapComparisonCellViewModelProtocol, data: Snap, filteredData: [Snap], sectionIndex: Int) {
        guard let date = data.createdAt else { return }
        self.viewModel = viewModel
        self.viewModel?.snapPhotos = data.imageUrls
        self.viewModel?.currentSectionIndex = sectionIndex
        self.viewModel?.filteredSnapData = filteredData
        snapCellDateLabel.text = updateDate(to: date)
        horizontalSnapPhotoCollectionView.reloadData()
    }
    
    func updateDate(to date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 d일"
        let updatedDateString = formatter.string(from: date)
        return updatedDateString
    }
}

// MARK: - UICollectionViewDelegate, DataSource Methods
extension SnapComparisonCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 1 }
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else { return UICollectionViewCell() }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalSnapPhotoCollectionViewCell.identifier, for: indexPath) as? HorizontalSnapPhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let imageUrlString = viewModel.snapPhotos[indexPath.row]
        if let imageUrl = URL(string: imageUrlString) {
            cell.snapPhoto.kf.setImage(with: imageUrl, placeholder: UIImage(systemName: "circle.dotted"))
        }
        
        if indexPath.row == 0 {
            cell.snapPhoto.layer.borderColor = UIColor.customMainColor?.cgColor
            cell.snapPhoto.layer.borderWidth = 3
            cell.snapPhoto.layer.cornerRadius = 30
            cell.snapPhoto.layer.masksToBounds = true
        } else {
            cell.snapPhoto.layer.borderWidth = 0.0
            cell.snapPhoto.layer.cornerRadius = 30
            cell.snapPhoto.layer.masksToBounds = true
        }
        cell.backgroundColor = .dynamicBackgroundInsideColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = SnapComparisonSheetViewModel()
        let sheetViewController = SnapComparisonSheetViewController(viewModel: viewModel)
        sheetViewController.modalPresentationStyle = .pageSheet
        
        guard let snapComparisonCellViewModel = self.viewModel else { return }
        
        sheetViewController.viewModel.filteredSnapData = snapComparisonCellViewModel.filteredSnapData
        viewModel.currentDateIndex = snapComparisonCellViewModel.currentSectionIndex
        viewModel.currentPhotoIndex = indexPath.row
        sheetViewController.snapDateLabel.text = snapCellDateLabel.text
        
        print("Selected Index: \(indexPath.section)")
        print("Current Date Index: \(viewModel.currentDateIndex)")
        
        if let sheet = sheetViewController.sheetPresentationController {
            // 뷰의 2/3크기로 모달 크기 설정
            let targetHeight = UIScreen.main.bounds.height * 2 / 3
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("customDetent")) { _ in
                return targetHeight
            }
                    
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
        }
        
        if let parentVC = self.parentViewController() {
            parentVC.present(sheetViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Methods
extension SnapComparisonCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height - 20
        return CGSize(width: height, height: height)
    }
    
}
