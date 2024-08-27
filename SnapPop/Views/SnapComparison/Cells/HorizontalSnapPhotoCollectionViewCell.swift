//
//  HorizontalSnapPhotoCollectionViewCell.swift
//  SnapPop
//
//  Created by 정종원 on 8/8/24.
//

import UIKit

class HorizontalSnapPhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "HorizontalSnapPhotoCollectionViewCell"

    /// 스냅 사진
    lazy var snapPhoto: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
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
    private func setupLayout() {
        
        contentView.backgroundColor = .customBackground
        
        contentView.addSubviews([
            snapPhoto
        ])
        
        NSLayoutConstraint.activate([
            snapPhoto.topAnchor.constraint(equalTo: contentView.topAnchor),
            snapPhoto.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            snapPhoto.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            snapPhoto.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
