//
//  CategorySettingsTableViewCell.swift
//  SnapPop
//
//  Created by 정종원 on 8/19/24.
//

import UIKit

class CategorySettingsTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "CategorySettingsTableViewCell"
    
    var saveEditButtonTapped: ((String) -> Void)?
    
    var isCategoryNameEditing = false
    
    // MARK: - UIComponents
    lazy var categoryNameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.isHidden = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var editCategoryNameButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "pencil")
        config.baseForegroundColor = .dynamicTextColor
        config.baseBackgroundColor = .customBackgroundColor
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func setupLayout() {
        contentView.addSubviews([
            categoryNameLabel,
            categoryNameTextField,
            editCategoryNameButton
        ])
        
        NSLayoutConstraint.activate([
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            categoryNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            categoryNameTextField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            categoryNameTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryNameTextField.trailingAnchor.constraint(equalTo: editCategoryNameButton.leadingAnchor, constant: -10),
            
            editCategoryNameButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            editCategoryNameButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc func didTapEditButton() {
        self.isCategoryNameEditing.toggle()
        if isCategoryNameEditing {
            categoryNameLabel.isHidden = true
            categoryNameTextField.isHidden = false
            categoryNameTextField.text = categoryNameLabel.text
            categoryNameTextField.becomeFirstResponder()
            editCategoryNameButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        } else {
            categoryNameLabel.isHidden = false
            categoryNameTextField.isHidden = true
            if let newName = categoryNameTextField.text, !newName.isEmpty {
                saveEditButtonTapped?(newName)
            }
            editCategoryNameButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        }
    }
}
