//
//  CustomTableViewCell.swift
//  SnapPop
//
//  Created by 이인호 on 8/19/24.
//
//
import UIKit

class BaseTableViewCell2: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {}
}

// -MARK: 제목
final class TitleCell2: BaseTableViewCell2 {
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

// -MARK: 설명
final class DescriptionCell: BaseTableViewCell2 {
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

// -MARK: 비용 추가
final class AddCostCell: BaseTableViewCell2 {
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

// -MARK: 1회 비용
final class OneTimeCostCell: BaseTableViewCell2 {
    static let identifier = "oneTimeCost"
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "1회 비용"
        
        return label
    }()
    
    private let costLabel: UILabel = {
        let label = UILabel()
        label.text = "000 원"
        label.textColor = .gray
        
        return label
    }()
    
    override func configureUI() {
        contentView.addSubview(label)
        contentView.addSubview(costLabel)
        selectionStyle = .none
        
        label.translatesAutoresizingMaskIntoConstraints = false
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            costLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            costLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func updateCost(with result: Int) {
        costLabel.text = "\(result) 원"
    }
}

// -MARK: 계산
final class CalculateCostCell: BaseTableViewCell2 {
    static let identifier = "calculateCost"
    
    var onCalculate: ((Int) -> Void)?
    
    private let purchasePriceLabel: UILabel = {
        let label = UILabel()
        label.text = "구매 가격"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    private lazy var purchasePriceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "가격을 입력해주세요"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.delegate = self
        
        return textField
    }()
    
    private let usageCountLabel: UILabel = {
        let label = UILabel()
        label.text = "예상 사용 횟수"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    private lazy var usageCountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "얼마나 쓸수있을까?"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.delegate = self
        
        return textField
    }()
    
    private lazy var calculateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("계산하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.customButtonColor
        button.layer.cornerRadius = 10
        
        button.addAction(UIAction { [weak self] _ in
            self?.calculate()
        }, for: .touchUpInside)
        return button
    }()
    
    override func configureUI() {
        contentView.addSubview(purchasePriceLabel)
        contentView.addSubview(purchasePriceTextField)
        contentView.addSubview(usageCountLabel)
        contentView.addSubview(usageCountTextField)
        contentView.addSubview(calculateButton)
        selectionStyle = .none
        
        purchasePriceLabel.translatesAutoresizingMaskIntoConstraints = false
        purchasePriceTextField.translatesAutoresizingMaskIntoConstraints = false
        usageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        usageCountTextField.translatesAutoresizingMaskIntoConstraints = false
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
            
            usageCountTextField.topAnchor.constraint(equalTo: usageCountLabel.bottomAnchor, constant: 8),
            usageCountTextField.leadingAnchor.constraint(equalTo: usageCountLabel.leadingAnchor),
            usageCountTextField.trailingAnchor.constraint(equalTo: usageCountLabel.trailingAnchor),
            usageCountTextField.heightAnchor.constraint(equalToConstant: 40),
            
            calculateButton.topAnchor.constraint(equalTo: usageCountTextField.bottomAnchor, constant: 32),
            calculateButton.leadingAnchor.constraint(equalTo: usageCountTextField.leadingAnchor),
            calculateButton.trailingAnchor.constraint(equalTo: usageCountTextField.trailingAnchor),
            calculateButton.heightAnchor.constraint(equalToConstant: 40),
            calculateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func calculate() {
        guard let purchasePriceText = purchasePriceTextField.text?.replacingOccurrences(of: "원", with: ""),
              let usageCountText = usageCountTextField.text?.replacingOccurrences(of: "회", with: ""),
              let purchasePrice = Int(purchasePriceText),
              let usageCount = Int(usageCountText),
              usageCount != 0 else {
            return
        }
        
        onCalculate?(purchasePrice / usageCount)
    }
}

// MARK: - UITableViewDataSource
extension CalculateCostCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 숫자가 아닌 경우 입력을 막음
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        
        var currentText = textField.text?.replacingOccurrences(of: "원", with: "").replacingOccurrences(of: "회", with: "") ?? ""
        
        if string.isEmpty {
            // 전체 선택 후 삭제 처리
            if range.length == textField.text?.count {
                textField.text = ""
                return false
            }
            currentText = String(currentText.dropLast()) // 백스페이스
        } else {
            currentText += string
        }
        
        if currentText.isEmpty {
            textField.text = ""
        } else {
            if textField == purchasePriceTextField {
                textField.text = "\(currentText)원"
            } else if textField == usageCountTextField {
                textField.text = "\(currentText)회"
            }
        }
        
        return false
    }
}
