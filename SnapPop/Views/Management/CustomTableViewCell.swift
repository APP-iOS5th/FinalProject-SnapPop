//
//  CustomTableViewCell.swift
//  SnapPop
//
//  Created by 장예진 on 8/13/24.
//

// -MARK: 셀에서 데이터 바인딩 관리
import UIKit

class BaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        // 상속된 클래스에서 오버라이드하여 사용
    }
    
    func setCornerRadius(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

// -MARK: 제목

class TitleCell: BaseTableViewCell {
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목 입력"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
// -MARK: 메모

class MemoCell: BaseTableViewCell {
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "메모 입력"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
// -MARK: 색상
class ColorCell: BaseTableViewCell {
    let colorPicker: UIColorWell = {
        let colorPicker = UIColorWell()
        colorPicker.supportsAlpha = false
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        return colorPicker
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(colorPicker)
        
        NSLayoutConstraint.activate([
            colorPicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
}
// -MARK: 날짜

class DateCell: BaseTableViewCell {
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
}
// -MARK: 반복
class RepeatCell: BaseTableViewCell {
    let repeatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("반복 주기 선택", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(repeatButton)
        
        NSLayoutConstraint.activate([
            repeatButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            repeatButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with viewModel: AddManagementViewModel) {
        let actions = viewModel.repeatOptions.enumerated().map { index, option in
            UIAction(title: option) { _ in
                viewModel.updateRepeatCycle(index)
                self.repeatButton.setTitle(option, for: .normal)
            }
        }
        
        repeatButton.menu = UIMenu(title: "반복 주기 선택", children: actions)
        repeatButton.showsMenuAsPrimaryAction = true
    }
}
// -MARK: 시간
class TimeCell: BaseTableViewCell {
    let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// -MARK: 알림
class NotificationCell: BaseTableViewCell {
    let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
}
