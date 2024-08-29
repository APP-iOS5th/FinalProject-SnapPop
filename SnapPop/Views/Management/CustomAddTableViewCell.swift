//
//  CustomTableViewCell.swift
//  SnapPop
//
//  Created by 장예진 on 8/13/24.
//

// -MARK: 셀에서 데이터 바인딩 관리
import UIKit

class BaseTableViewCell: UITableViewCell {
    private var maskLayer: CAShapeLayer?
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.width > 0 && bounds.height > 0 {
            if maskLayer == nil {
                maskLayer = CAShapeLayer()
                layer.mask = maskLayer
            }
            
            if let tableView = superview as? UITableView,
               let indexPath = tableView.indexPath(for: self) {
                let cornerRadius: CGFloat = 10.0
                let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)

                var corners: UIRectCorner = []
                if numberOfRows == 1 {
                    corners = .allCorners
                } else if indexPath.row == 0 {
                    corners = [.topLeft, .topRight]
                } else if indexPath.row == numberOfRows - 1 {
                    corners = [.bottomLeft, .bottomRight]
                }
                
                let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
                maskLayer?.path = path.cgPath
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        maskLayer?.removeFromSuperlayer()
        maskLayer = nil
    }
}


// -MARK: 제목

class TitleCell: BaseTableViewCell {
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목(ex:물 한 잔 마시기)"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(textField)
        selectionStyle = .none

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
        textField.placeholder = "메모(ex: 따뜻하게) "
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(textField)
        selectionStyle = .none

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
        selectionStyle = .none

        NSLayoutConstraint.activate([
            colorPicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
}
// -MARK: 날짜
class DateCell: BaseTableViewCell {
    var dismissHandler: (() -> Void)?
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.locale = Locale(identifier: "ko_KR")
        return datePicker
    }()
    
    override func setupUI() {
        super.setupUI()
        textLabel?.text = "날짜"
        imageView?.image = UIImage(systemName: "calendar")
        imageView?.tintColor = .black
        
        contentView.addSubview(datePicker)
        selectionStyle = .none

        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    func configure(with date: Date) {
        datePicker.date = date
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        dismissHandler?()
    }
}

// -MARK: 반복
class RepeatCell: BaseTableViewCell {
    let repeatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("안함", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        let arrowImage = UIImage(systemName: "chevron.up.chevron.down")
        button.setImage(arrowImage, for: .normal)
        
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(repeatButton)
        selectionStyle = .none

        NSLayoutConstraint.activate([
            repeatButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            repeatButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with viewModel: AddManagementViewModel) {

        let index = viewModel.repeatOptions.firstIndex { option in
            switch option {
            case "매일":
                return viewModel.repeatCycle == 1
            case "매주":
                return viewModel.repeatCycle == 7
            case "안함":
                return viewModel.repeatCycle == 0
            default:
                return false
            }
        } ?? 2 // 기본값으로 "안함"을 선택
        

        repeatButton.setTitle(viewModel.repeatOptions[index], for: .normal)
        
        let actions = viewModel.repeatOptions.enumerated().map { idx, option in
            UIAction(title: option) { _ in
                viewModel.updateRepeatCycle(idx)
                self.repeatButton.setTitle(option, for: .normal)
            }
        }
        
        repeatButton.menu = UIMenu(title: "", children: actions)
        repeatButton.showsMenuAsPrimaryAction = true
    }
}


// -MARK: 시간
class TimeCell: BaseTableViewCell {
    let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(timePicker)
        selectionStyle = .none

        NSLayoutConstraint.activate([
            timePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            timePicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            timePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// -MARK: 알림
class NotificationCell: BaseTableViewCell {
    let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = UIColor.customToggleColor
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    weak var delegate: NotificationCellDelegate?
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(switchControl)
        selectionStyle = .none

        NSLayoutConstraint.activate([
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    @objc private func switchValueChanged() {
        delegate?.notificationCellDidToggle(self, isOn: switchControl.isOn)
    }
}

protocol NotificationCellDelegate: AnyObject {
    func notificationCellDidToggle(_ cell: NotificationCell, isOn: Bool)
}

class DetailCostCell: BaseTableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private let oneTimeLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private let oneTimeCostLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        
        return label
    }()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubview(titleLabel)
        contentView.addSubview(oneTimeLabel)
        contentView.addSubview(oneTimeCostLabel)
        selectionStyle = .none
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        oneTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        oneTimeCostLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            oneTimeLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 80),
            oneTimeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            oneTimeCostLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            oneTimeCostLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with detailCost: DetailCost) {
        titleLabel.text = detailCost.title
        if let oneTimeCost = detailCost.oneTimeCost {
            oneTimeLabel.text = "1회"
            oneTimeCostLabel.text = "\(String(oneTimeCost))원"
        } else {
            oneTimeCostLabel.text = nil
        }
    }
}
