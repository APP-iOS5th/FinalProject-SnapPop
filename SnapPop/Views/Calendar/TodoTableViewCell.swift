//
//  TodoTableViewCell.swift
//  SnapPop
//
//  Created by 김형준 on 8/19/24.
//
import UIKit

import UIKit

class TodoTableViewCell: UITableViewCell {
    
    let checkboxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .customToggle
        return button
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCellViews()
    }
    
    private func setupCellViews() {
        contentView.addSubview(checkboxButton)
        contentView.addSubview(label)
        
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 30),
            checkboxButton.heightAnchor.constraint(equalToConstant: 30),
            
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        updateCheckboxState(isChecked: false)
    }
    
    func updateCheckboxState(isChecked: Bool) {
        checkboxButton.isSelected = isChecked
        let imageName = isChecked ? "checkmark.circle.fill" : "circle"
        if let image = UIImage(systemName: imageName) {
            let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
            let resizedImage = image.withConfiguration(configuration)
            checkboxButton.setImage(resizedImage, for: .normal)
        }
        checkboxButton.imageView?.contentMode = .scaleAspectFit
    }
    
    func updateCheckboxColor(color: String) {
        if let newColor = UIColor(hex: color) {
            checkboxButton.tintColor = newColor
        } else {
            checkboxButton.tintColor = .customToggle
        }
    }
    
    func setLabelText(_ text: String, isManagementEmpty: Bool) {
        if isManagementEmpty {
            label.text = text
            label.textAlignment = .center
            checkboxButton.isHidden = true
        } else {
            // 체크박스 너비만큼 왼쪽에 공백 추가
            let spaceWidth = checkboxButton.frame.width + 33 // 체크박스 너비 + 오른쪽 여백
            let spaceString = String(repeating: " ", count: Int(spaceWidth / 7)) // 대략적인 공백 문자 수 계산
            label.text = spaceString + text
            label.textAlignment = .left
            checkboxButton.isHidden = false
        }
    }
}
