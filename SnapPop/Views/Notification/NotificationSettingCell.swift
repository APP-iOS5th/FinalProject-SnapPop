//
//  NotificationSettingCell.swift
//  SnapPop
//
//  Created by 정종원 on 8/29/24.
//

import UIKit

class NotificationSettingCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "NotificationSettingCell"
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let selectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        button.isHidden = true
        return button
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func setupLayout() {
        contentView.addSubviews([
            titleLabel,
            toggleSwitch,
            selectionButton
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            selectionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            selectionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func recomendCellConfigure(title: String, isOn: Bool) {
        titleLabel.text = title
        toggleSwitch.isHidden = false
        toggleSwitch.isOn = isOn
        selectionButton.isHidden = true
    }
    
    func managementCellConfigure(title: String, menuItems: [UIAction]) {
        titleLabel.text = title
        let menu = UIMenu(title: "", children: menuItems)
        selectionButton.menu = menu
        selectionButton.setTitle("시간 설정", for: .normal)
        toggleSwitch.isHidden = true
        selectionButton.isHidden = false
    }
    
    func configure(title: String, isOn: Bool) {
        titleLabel.text = title
        toggleSwitch.isOn = isOn
    }
    
}
