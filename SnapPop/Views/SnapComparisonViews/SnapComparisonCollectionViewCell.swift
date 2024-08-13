//
//  SnapComparisonCollectionViewCell.swift
//  SnapPop
//
//  Created by 정종원 on 8/8/24.
//

import UIKit

class SnapComparisonCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    private var viewModel: SnapComparisonViewModel?
    private var snapPhotos: [UIImage] = []
    /// 현재 섹션의 인덱스 저장 변수
    private var currentSectionIndex: Int = 0
    
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
        collectionView.register(HorizontalSnapPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "HorizontalSnapPhotoCollectionViewCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    // MARK: - Initializers
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
    
    func configure(with data: Snap, viewModel: SnapComparisonViewModel, sectionIndex: Int) {
        snapCellDateLabel.text = data.date
        snapPhotos = data.images
        horizontalSnapPhotoCollectionView.reloadData()
        self.viewModel = viewModel
        self.currentSectionIndex = sectionIndex
    }
}

// MARK: - UICollectionViewDelegate, DataSource Methods
extension SnapComparisonCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        snapPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalSnapPhotoCollectionViewCell", for: indexPath) as? HorizontalSnapPhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.snapPhoto.image = snapPhotos[indexPath.row]
        
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
        guard let viewModel = viewModel else { return }
        let sheetViewController = SnapComparisonSheetViewController()
        sheetViewController.modalPresentationStyle = .pageSheet
        viewModel.selectedIndex = indexPath.row
        viewModel.currentDateIndex = self.currentSectionIndex
        sheetViewController.viewModel = self.viewModel
        sheetViewController.snapDateLabel.text = snapCellDateLabel.text
        
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

#Preview {
    SnapComparisonCollectionViewCell()
}
