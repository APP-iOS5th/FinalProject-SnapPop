//
//  ChecklistTableViewCell.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/13/24.
//

import UIKit

class ChecklistTableViewCell: UITableViewCell {
    
    // 체크버튼
    let checkBox: UIButton = {
         let button = UIButton(type: .custom)
         button.translatesAutoresizingMaskIntoConstraints = false
         return button
     }()
    
    // check항목 레이블
    let checkLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 셀 내부에 UI 요소 추가
        contentView.addSubview(checkBox)
        contentView.addSubview(checkLabel)
        
        // 체크박스와 텍스트 레이블 제약 조건 설정
        NSLayoutConstraint.activate([
            
            // 체크박스 제약 조건
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBox.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            checkBox.heightAnchor.constraint(equalTo: checkBox.widthAnchor), 
            
            // 텍스트 레이블 제약 조건
            checkLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 15),
            checkLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
        
        // 체크박스 클릭 시 상태 변화
        checkBox.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Cell with Checklist Item
    func configure(with item: Management) {
        checkLabel.text = item.title
        
        // 색상 설정
        if let color = UIColor(hex: item.color) {
            checkLabel.textColor = color
            updateCheckBoxImages(with: color)
        } else {
            checkLabel.textColor = .black
        }
        
        // 체크박스 상태 설정 (일단 임시)
        checkBox.isSelected = item.alertStatus
    }
    
    // MARK: - Update CheckBox Images with Color
    private func updateCheckBoxImages(with color: UIColor) {
          let noncheckmarkImage = UIImage(systemName: "circle")?.withTintColor(color, renderingMode: .alwaysOriginal)
          let checkmarkImage = UIImage(systemName: "circle.fill")?.withTintColor(color, renderingMode: .alwaysOriginal)
          checkBox.setImage(noncheckmarkImage, for: .normal)
          checkBox.setImage(checkmarkImage, for: .selected)
      }
    
    // 체크박스 버튼 클릭 시 호출되는 메서드
    @objc private func didTapCheckBox() {
        checkBox.isSelected.toggle()
    }
    
}

// 임시 위치
extension UIColor {
    convenience init?(hex: String) {
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
