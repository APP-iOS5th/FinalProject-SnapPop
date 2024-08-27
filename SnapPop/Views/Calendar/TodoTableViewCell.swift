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
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = .customToggle
        return button
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCellViews()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellViews() {
        contentView.addSubview(checkboxButton)
        contentView.addSubview(label)
        
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                checkboxButton.widthAnchor.constraint(equalToConstant: 24),
                checkboxButton.heightAnchor.constraint(equalToConstant: 24),
                
                label.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        
    }
    
    func updateCheckbocState(isChecked: Bool) {
        checkboxButton.isSelected = isChecked
        let image = isChecked ? UIImage(systemName: "circle.fill") : UIImage(systemName: "circle")
        checkboxButton.setImage(image, for: .normal)
    }
}
