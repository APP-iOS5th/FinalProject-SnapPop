//
//  AppLockSettingTableViewCell.swift
//  SnapPop
//
//  Created by 이인호 on 8/12/24.
//

import UIKit

class AppLockSettingTableViewCell: UITableViewCell {
    static let identifier = "appLockSetting"
    
    private let appLockSettingLabel: UILabel = {
        let label = UILabel()
        label.text = "앱 잠금"
        
        return label
    }()
    
    private let appLockToggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        
        toggleSwitch.isOn = UserDefaults.standard.bool(forKey: "appLockState")
        toggleSwitch.onTintColor = UIColor.customToggleColor
        toggleSwitch.addAction(UIAction { _ in
            UserDefaults.standard.set(toggleSwitch.isOn, forKey: "appLockState")
        }, for: .valueChanged)
        
        return toggleSwitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubview(appLockSettingLabel)
        contentView.addSubview(appLockToggleSwitch)
        selectionStyle = .none
        
        appLockSettingLabel.translatesAutoresizingMaskIntoConstraints = false
        appLockToggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            appLockSettingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            appLockSettingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            appLockToggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            appLockToggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
