//
//  ChecklistTableViewCell.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/13/24.
//

import UIKit

class ChecklistTableViewCell: UITableViewCell {
    
    var managementId: String? // 관리 항목 ID를 저장할 변수 추가
    var onCheckBoxToggle: ((String, Bool) -> Void)? // 체크박스 상태 변경 시 호출할 클로저 추가

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
        label.font = UIFont.systemFont(ofSize: 19)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(checkBox)
        contentView.addSubview(checkLabel)
        
        NSLayoutConstraint.activate([
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBox.widthAnchor.constraint(equalToConstant: 30),
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
    func configure(with item: Management, for date: Date) {
//        print("Configuring cell with item: \(item)")
        managementId = item.id // 관리 항목 ID 설정

        checkLabel.text = item.title
        
        // 체크박스 색상 설정
        if let color = UIColor(hex: item.color) {
            checkBox.layer.borderColor = color.cgColor
            checkBox.tintColor = color
        } else {
            // 색상이 유효하지 않을 경우 기본 색상으로 설정
            checkBox.layer.borderColor = UIColor.lightGray.cgColor
            checkBox.tintColor = UIColor.lightGray
        }
        
        // 선택된 날짜에 따라 체크박스 상태 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let isChecked = item.completions[dateString] == 1
        checkBox.isSelected = isChecked
        updateCheckboxState(isChecked: isChecked)
    }
    
    // MARK: - 체크박스 이미지 업데이트
    func updateCheckboxState(isChecked: Bool) {
            guard let emptyImage = UIImage(named: "emptypopcorn"),
                  let filledImage = UIImage(named: "filledpop") else {
                return
            }
            
            let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
            let resizedEmptyImage = emptyImage.withConfiguration(configuration)
            let resizedFilledImage = filledImage.withConfiguration(configuration)
            
            if isChecked {
                let coloredFilledImage = fillImage(originalImage: resizedFilledImage, withColor: checkBox.tintColor)
                let combinedImage = overlayImages(bottomImage: coloredFilledImage, topImage: resizedEmptyImage)
                checkBox.setImage(combinedImage, for: .normal)
            } else {
                checkBox.setImage(resizedEmptyImage, for: .normal)
            }
            
            checkBox.imageView?.contentMode = .scaleAspectFit		
            checkBox.contentHorizontalAlignment = .fill
            checkBox.contentVerticalAlignment = .fill
        }

    @objc private func didTapCheckBox() {
        checkBox.isSelected.toggle()
        updateCheckboxState(isChecked: checkBox.isSelected) // 체크박스 상태 업데이트
        if let managementId = managementId {
            onCheckBoxToggle?(managementId, checkBox.isSelected)
        }
    }
    
    private func currentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    func fillImage(originalImage: UIImage, withColor color: UIColor) -> UIImage {
            let rect = CGRect(origin: .zero, size: originalImage.size)
            
            UIGraphicsBeginImageContextWithOptions(originalImage.size, false, originalImage.scale)
            defer { UIGraphicsEndImageContext() }
            
            guard let context = UIGraphicsGetCurrentContext() else {
                return originalImage
            }
            
            originalImage.draw(in: rect)
            
            context.setBlendMode(.sourceAtop)
            context.setFillColor(color.cgColor)
            context.fill(rect)
            
            return UIGraphicsGetImageFromCurrentImageContext() ?? originalImage
        }
        
        func overlayImages(bottomImage: UIImage, topImage: UIImage) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(bottomImage.size, false, 0.0)
            defer { UIGraphicsEndImageContext() }
            
            bottomImage.draw(in: CGRect(origin: .zero, size: bottomImage.size))
            topImage.draw(in: CGRect(origin: .zero, size: topImage.size))
            
            return UIGraphicsGetImageFromCurrentImageContext() ?? bottomImage
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
