//
//  SnapComparisonCollectionViewCell.swift
//  SnapPop
//
//  Created by 정종원 on 8/8/24.
//

import UIKit

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
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HorizontalSnapPhotoCollectionViewCell.self, forCellWithReuseIdentifier: HorizontalSnapPhotoCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
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
            horizontalSnapPhotoCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            horizontalSnapPhotoCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            horizontalSnapPhotoCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            horizontalSnapPhotoCollectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
    }
    
    func configure(with viewModel: SnapComparisonCellViewModelProtocol, data: MockSnap, filteredData: [MockSnap], sectionIndex: Int) {
        self.viewModel = viewModel
        self.viewModel?.snapPhotos = data.images
        self.viewModel?.currentSectionIndex = sectionIndex
        self.viewModel?.filteredSnapData = filteredData
        snapCellDateLabel.text = data.date
        horizontalSnapPhotoCollectionView.reloadData()
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
        
        cell.snapPhoto.image = viewModel.snapPhotos[indexPath.row]
        
        if indexPath.row == 0 {
            // 절대값 수정 해야할듯
            cell.snapPhoto.layer.borderColor = UIColor(red: 0.57, green: 0.87, blue: 0.91, alpha: 1.00).cgColor
            cell.snapPhoto.layer.borderWidth = 3
            cell.snapPhoto.layer.cornerRadius = 30
            cell.snapPhoto.layer.masksToBounds = true
        } else {
            cell.snapPhoto.layer.borderWidth = 0.0
            cell.snapPhoto.layer.cornerRadius = 30
        }
        
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
            sheet.detents = [.medium()]
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