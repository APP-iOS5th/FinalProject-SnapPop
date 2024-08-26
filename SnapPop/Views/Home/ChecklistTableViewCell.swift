//
//  ChecklistTableViewCell.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/13/24.
//

import UIKit

class ChecklistTableViewCell: UITableViewCell {
    
    // 체크박스 버튼
    let checkBox: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 체크리스트 항목 레이블
    let checkLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 텍스트 필드 (편집 모드에서 사용)
    let textField: UITextField = {
        let textField = UITextField()
        textField.isHidden = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(checkBox)
        contentView.addSubview(checkLabel)
        contentView.addSubview(textField) // 텍스트 필드 추가
        
        NSLayoutConstraint.activate([
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBox.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            checkBox.heightAnchor.constraint(equalTo: checkBox.widthAnchor),
            
            checkLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 15),
            checkLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            textField.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 15),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
        
        checkBox.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: .editingDidEnd)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Cell with Checklist Item
    func configure(with item: Management) {
        checkLabel.text = item.title
        textField.text = item.title
        
        // 색상 설정
        if let color = UIColor(hex: item.color) {
            checkLabel.textColor = color
            updateCheckBoxImages(with: color)
        } else {
            checkLabel.textColor = .black
        }
        
        // 체크박스 상태 설정
        checkBox.isSelected = item.alertStatus
    }
    
    // MARK: - 체크박스 이미지 업데이트
    private func updateCheckBoxImages(with color: UIColor) {
        let noncheckmarkImage = UIImage(systemName: "circle")?.withTintColor(color, renderingMode: .alwaysOriginal)
        let checkmarkImage = UIImage(systemName: "circle.fill")?.withTintColor(color, renderingMode: .alwaysOriginal)
        checkBox.setImage(noncheckmarkImage, for: .normal)
        checkBox.setImage(checkmarkImage, for: .selected)
    }
    
    // 체크박스 클릭 시 상태 변화
    @objc private func didTapCheckBox() {
        checkBox.isSelected.toggle()
    }
    
    // 편집 모드로 전환
    func enterEditMode() {
        checkLabel.isHidden = true
        textField.isHidden = false
        textField.becomeFirstResponder() // 자동으로 키보드가 나타남
    }
    
    // 편집 종료시 호출
    @objc private func textFieldEditingDidEnd() {
        checkLabel.text = textField.text
        checkLabel.isHidden = false
        textField.isHidden = true
    }
}

// UIColor 확장 - HEX 문자열을 UIColor로 변환
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
