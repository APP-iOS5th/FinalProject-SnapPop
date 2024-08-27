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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(checkBox)
        contentView.addSubview(checkLabel)
        
        NSLayoutConstraint.activate([
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBox.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            checkBox.heightAnchor.constraint(equalTo: checkBox.widthAnchor),
            
            checkLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 15),
            checkLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
        
        checkBox.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
        
        selectionStyle = .none

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Cell with Checklist Item
    func configure(with item: Management) {
        print("Configuring cell with item: \(item)")
        
        checkLabel.text = item.title
        
        // 체크박스 색상 설정
        if let color = UIColor(hex: item.color) {
            updateCheckBoxImages(with: color)
            checkBox.layer.borderColor = color.cgColor
            checkBox.tintColor = color
        } else {
            // 색상이 유효하지 않을 경우 기본 색상으로 설정
            checkBox.layer.borderColor = UIColor.lightGray.cgColor
            checkBox.tintColor = UIColor.lightGray
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
}

// UIColor 확장 - HEX 문자열을 UIColor로 변환
extension UIColor {
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgb) else { return nil }
        
        let red, green, blue: CGFloat
        
        switch hexString.count {
        case 6:
            red = CGFloat((rgb >> 16) & 0xFF) / 255.0
            green = CGFloat((rgb >> 8) & 0xFF) / 255.0
            blue = CGFloat(rgb & 0xFF) / 255.0
        case 8: // ARGB format
            red = CGFloat((rgb >> 16) & 0xFF) / 255.0
            green = CGFloat((rgb >> 8) & 0xFF) / 255.0
            blue = CGFloat(rgb & 0xFF) / 255.0
        default:
            return nil
        }
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
