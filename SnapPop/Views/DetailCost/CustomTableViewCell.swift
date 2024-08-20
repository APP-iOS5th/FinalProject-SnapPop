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
    
    var onToggleSwitchChanged: ((Bool) -> Void)?
    
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
        
        toggleSwitch.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.onToggleSwitchChanged?(self.toggleSwitch.isOn)
        }, for: .valueChanged)
    }
}

final class OneTimeCostCell: BaseTableViewCell {
    static let identifier = "oneTimeCost"
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "1회 비용"
        
        return label
    }()
    
    private let cost: UILabel = {
        let label = UILabel()
        label.text = "000 원"
        label.textColor = .gray
        
        return label
    }()
    
    override func configureUI() {
        contentView.addSubview(label)
        contentView.addSubview(cost)
        selectionStyle = .none
        
        label.translatesAutoresizingMaskIntoConstraints = false
        cost.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            cost.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cost.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

final class CalculateCostCell: BaseTableViewCell {
    static let identifier = "calculateCost"
    
    private let purchasePriceLabel: UILabel = {
        let label = UILabel()
        label.text = "구매 가격"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    private let purchasePriceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "000"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        
        return textField
    }()
    
    private let usageCountLabel: UILabel = {
        let label = UILabel()
        label.text = "예상 사용 횟수"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    private let usageCoutTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "000"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        
        return textField
    }()
    
    private let calculateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("계산하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.customButtonColor
        button.layer.cornerRadius = 10
        
        button.addAction(UIAction { _ in
            print("hi")
        }, for: .touchUpInside)
        return button
    }()
    
    override func configureUI() {
        contentView.addSubview(purchasePriceLabel)
        contentView.addSubview(purchasePriceTextField)
        contentView.addSubview(usageCountLabel)
        contentView.addSubview(usageCoutTextField)
        contentView.addSubview(calculateButton)
        selectionStyle = .none
        
        purchasePriceLabel.translatesAutoresizingMaskIntoConstraints = false
        purchasePriceTextField.translatesAutoresizingMaskIntoConstraints = false
        usageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        usageCoutTextField.translatesAutoresizingMaskIntoConstraints = false
        calculateButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            purchasePriceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            purchasePriceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            purchasePriceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            purchasePriceTextField.topAnchor.constraint(equalTo: purchasePriceLabel.bottomAnchor, constant: 8),
            purchasePriceTextField.leadingAnchor.constraint(equalTo: purchasePriceLabel.leadingAnchor),
            purchasePriceTextField.trailingAnchor.constraint(equalTo: purchasePriceLabel.trailingAnchor),
            purchasePriceTextField.heightAnchor.constraint(equalToConstant: 40),
            
            usageCountLabel.topAnchor.constraint(equalTo: purchasePriceTextField.bottomAnchor, constant: 16),
            usageCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            usageCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            usageCoutTextField.topAnchor.constraint(equalTo: usageCountLabel.bottomAnchor, constant: 8),
            usageCoutTextField.leadingAnchor.constraint(equalTo: usageCountLabel.leadingAnchor),
            usageCoutTextField.trailingAnchor.constraint(equalTo: usageCountLabel.trailingAnchor),
            usageCoutTextField.heightAnchor.constraint(equalToConstant: 40),
            
            calculateButton.topAnchor.constraint(equalTo: usageCoutTextField.bottomAnchor, constant: 32),
            calculateButton.leadingAnchor.constraint(equalTo: usageCoutTextField.leadingAnchor),
            calculateButton.trailingAnchor.constraint(equalTo: usageCoutTextField.trailingAnchor),
            calculateButton.heightAnchor.constraint(equalToConstant: 40),
            calculateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
}
