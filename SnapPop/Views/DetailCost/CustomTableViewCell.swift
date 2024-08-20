//
//  CustomTableViewCell.swift
//  SnapPop
//
//  Created by 이인호 on 8/19/24.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {}
}

final class TitleCell: BaseTableViewCell {
    static let identifier = "title"
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목 (ex: 제품 이름)"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        return textField
    }()
    
    override func configureUI() {
        contentView.addSubview(textField)
        selectionStyle = .none
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

final class DescriptionCell: BaseTableViewCell {
    static let identifier = "description"
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "설명"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        return textField
    }()
    
    override func configureUI() {
        contentView.addSubview(textField)
        selectionStyle = .none
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

final class AddCostCell: BaseTableViewCell {
    static let identifier = "addCost"
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "비용 추가"
        
        return label
    }()
    
    let toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.onTintColor = UIColor.customToggleColor
        
        return toggleSwitch
    }()
    
    override func configureUI() {
        contentView.addSubview(label)
        contentView.addSubview(toggleSwitch)
        selectionStyle = .none
        
        label.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
