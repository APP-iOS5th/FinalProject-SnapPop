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
    
    // MARK: - UIComponents
    lazy var categoryNameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        contentView.addSubview(categoryNameLabel)
        
        NSLayoutConstraint.activate([
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            categoryNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
