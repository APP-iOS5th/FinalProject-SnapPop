//
//  SnapCollectionViewCell.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/12/24.
//

import UIKit
import Photos

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

class SnapCollectionViewCell: UICollectionViewCell {
    
    let snapImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        let deleteImage = UIImage(systemName: "minus.circle.fill")
        button.setImage(deleteImage, for: .normal)
        button.tintColor = .red
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(snapImageView)
        contentView.addSubview(deleteButton)
        
        snapImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 이미지 뷰 제약 조건
            snapImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            snapImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            snapImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            snapImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // 삭제 버튼 제약 조건
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.bounds.height * 0.02),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentView.bounds.width * 0.02),
            deleteButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.1),
            deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 셀의 상태 초기화
        snapImageView.image = nil
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
    }
    
    func configure(with snap: Snap, index: Int, isFirst: Bool, isEditing: Bool) {
        // 첫 번째 셀의 테두리 설정
        if isFirst {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = UIColor.customMainColor?.cgColor
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
        }
        
        let url = URL(string: snap.imageUrls[index])
        snapImageView.load(url: url!)
        
        // 편집 모드에 따라 삭제 버튼 표시
        setEditingMode(isEditing)
//        // PHAssetIdentifier를 사용하여 PHAsset을 가져옵니다.
//        if let firstImageUrl = snap.imageUrls.first {
//            let url = URL(string: firstImageUrl)
//            snapImageView.load(url: url!)
////            if let asset = fetchPHAsset(for: firstImageUrl) {
////                loadImage(from: asset)
////            } else {
////                snapImageView.image = nil // PHAsset을 찾을 수 없는 경우
////            }
//        } else {
//            snapImageView.image = nil // 이미지 URL이 없는 경우
//        }
    }
    
    func setEditingMode(_ isEditing: Bool) {
        deleteButton.isHidden = !isEditing
    }
    
    private func fetchPHAsset(for identifier: String) -> PHAsset? {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        return fetchResult.firstObject
    }
    
    private func loadImage(from asset: PHAsset) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true // 동기 요청
        requestOptions.deliveryMode = .highQualityFormat

        imageManager.requestImage(for: asset, targetSize: snapImageView.bounds.size, contentMode: .aspectFill, options: requestOptions) { [weak self] image, _ in
            DispatchQueue.main.async {
                self?.snapImageView.image = image
            }
        }
    }
}
