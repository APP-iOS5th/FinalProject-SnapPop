//
//  SnapCollectionViewCell.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/12/24.
//

import UIKit

// MARK : 스냅사진 컬렉션 뷰에 사용 되는 사진 셀
class SnapCollectionViewCell: UICollectionViewCell {
    
    let snapImageView: UIImageView = {
        let snapimageView = UIImageView()
        snapimageView.contentMode = .scaleAspectFill // 이미지 비율 유지
        snapimageView.clipsToBounds = true
        return snapimageView
    }()
    
    let deleteButton: UIButton = {
        let deletebutton = UIButton(type: .custom)
        let deletimage = UIImage(systemName: "minus.circle")
        deletebutton.setImage(deletimage, for: .normal)
        deletebutton.tintColor = .red
        deletebutton.isHidden = true
        return deletebutton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(snapImageView)
        contentView.addSubview(deleteButton)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        snapImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 이미지 뷰 제약 조건
            snapImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            snapImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            snapImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            snapImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // 편집 버튼 제약 조건
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with snap: Snap, isFirst: Bool, isEditing: Bool) {
        
        // 첫 번째 셀의 테두리 설정
        if isFirst {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = UIColor(red: 92/255, green: 223/255, blue: 231/255, alpha: 1.0).cgColor
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
        }
        
        // 편집 모드에 따라 삭제 버튼 표시
        deleteButton.isHidden = !isEditing
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            snapImageView.image = nil
            return
        }
        // 로컬 이미지
        if let image = UIImage(named: urlString) {
            snapImageView.image = image
        } else {
            snapImageView.image = nil
        }
        
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let data = data, let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self.snapImageView.image = image
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.snapImageView.image = nil
//                }
//            }
//        }
//        task.resume()
    }
}
