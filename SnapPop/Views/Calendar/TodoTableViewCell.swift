//
//  TodoTableViewCell.swift
//  SnapPop
//
//  Created by 김형준 on 8/19/24.
//
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
            checkboxButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 35),
            checkboxButton.heightAnchor.constraint(equalToConstant: 35),
            
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 23),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        updateCheckboxState(isChecked: false)
    }
    
    func updateCheckboxState(isChecked: Bool) {
        checkboxButton.isSelected = isChecked
        
        guard let emptyImage = UIImage(named: "emptypopcorn"),
              let filledImage = UIImage(named: "filledpop"),
              let emptyWhiteImage = UIImage(named: "emptypop")
        else {
            return
        }
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular)
        let resizedEmptyImage = emptyImage.withConfiguration(configuration)
        let resizedEmptyWhiteImage = emptyWhiteImage.withConfiguration(configuration)
        let resizedFilledImage = filledImage.withConfiguration(configuration)
        
        if isChecked {
            let coloredFilledImage = fillImage(originalImage: resizedFilledImage, withColor: checkboxButton.tintColor)
            let combinedImage = overlayImages(bottomImage: coloredFilledImage, topImage: resizedEmptyImage)
            checkboxButton.setImage(combinedImage, for: .normal)
        } else {
            checkboxButton.setImage(resizedEmptyWhiteImage, for: .normal)
        }
        
        checkboxButton.imageView?.contentMode = .scaleAspectFit
    }
    
    func updateCheckboxColor(color: String) {
        if let newColor = UIColor(hex: color) {
            checkboxButton.tintColor = newColor
            updateCheckboxState(isChecked: checkboxButton.isSelected)
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
            let spaceWidth = checkboxButton.frame.width + 34
            let spaceString = String(repeating: " ", count: Int(spaceWidth / 7))
            label.text = spaceString + text
            label.textAlignment = .left
            checkboxButton.isHidden = false
        }
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
