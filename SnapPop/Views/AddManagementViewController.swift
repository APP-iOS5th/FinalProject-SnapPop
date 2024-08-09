//
//  AddManagementViewController.swift
//  SnapPop
//
//  Created by 장예진 on 8/8/24.
//

import UIKit

class AddManagementViewController: UIViewController {
    private let viewModel: AddManagementViewModel
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목 입력"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "색상"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let colorPicker: UIColorWell = {
        let colorWell = UIColorWell()
        colorWell.supportsAlpha = false
        colorWell.translatesAutoresizingMaskIntoConstraints = false
        return colorWell
    }()
    
    private let memoLabel: UILabel = {
        let label = UILabel()
        label.text = "메모"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let memoTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "메모 입력"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "날짜"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let repeatLabel: UILabel = {
        let label = UILabel()
        label.text = "반복"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let repeatSegmentedControl: UISegmentedControl = {
        let items = ["매주", "매일", "매달", "안함"]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "시간"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.isHidden = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "알림"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notificationSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.text = "상세 내역 및 비용"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addDetailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("상세 비용 추가하기 +", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: AddManagementViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, titleTextField, colorLabel, colorPicker, memoLabel, memoTextField,
         dateLabel, datePicker, repeatLabel, repeatSegmentedControl, timeLabel, timeSwitch,
         timePicker, notificationLabel, notificationSwitch, detailsLabel, addDetailButton].forEach { contentView.addSubview($0) }
        
        setupConstraints()
        
        title = "새로운 자기 관리"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(saveButtonTapped))
    }
    
    private func setupConstraints() {
        let margin: CGFloat = 20
        let spacing: CGFloat = 15
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            
            colorLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: margin),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            colorPicker.centerYAnchor.constraint(equalTo: colorLabel.centerYAnchor),
            colorPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            
            memoLabel.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: margin),
            memoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            memoTextField.topAnchor.constraint(equalTo: memoLabel.bottomAnchor, constant: spacing),
            memoTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            memoTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            
            dateLabel.topAnchor.constraint(equalTo: memoTextField.bottomAnchor, constant: margin),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            datePicker.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            
            repeatLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: margin),
            repeatLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            repeatSegmentedControl.centerYAnchor.constraint(equalTo: repeatLabel.centerYAnchor),
            repeatSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            
            timeLabel.topAnchor.constraint(equalTo: repeatLabel.bottomAnchor, constant: margin),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            timeSwitch.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            timeSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            
            timePicker.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: spacing),
            timePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            
            notificationLabel.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: margin),
            notificationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            notificationSwitch.centerYAnchor.constraint(equalTo: notificationLabel.centerYAnchor),
            notificationSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            
            detailsLabel.topAnchor.constraint(equalTo: notificationLabel.bottomAnchor, constant: margin * 2),
            detailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            detailsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            
            addDetailButton.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: spacing),
            addDetailButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            addDetailButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            addDetailButton.heightAnchor.constraint(equalToConstant: 44),
            addDetailButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin)
        ])
    }
    
    private func setupBindings() {
        titleTextField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
        colorPicker.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
        memoTextField.addTarget(self, action: #selector(memoChanged), for: .editingChanged)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        repeatSegmentedControl.addTarget(self, action: #selector(repeatTypeChanged), for: .valueChanged)
        timeSwitch.addTarget(self, action: #selector(timeSwitchChanged), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
        notificationSwitch.addTarget(self, action: #selector(notificationChanged), for: .valueChanged)
        addDetailButton.addTarget(self, action: #selector(addDetailButtonTapped), for: .touchUpInside)
    }
    
    @objc private func titleChanged() {
        viewModel.updateTitle(titleTextField.text ?? "")
    }
    
    @objc private func colorChanged() {
        viewModel.updateColor(colorPicker.selectedColor ?? .black)
    }
    
    @objc private func memoChanged() {
        viewModel.updateMemo(memoTextField.text ?? "")
    }
    
    @objc private func dateChanged() {
        viewModel.updateDate(datePicker.date)
    }
    
    @objc private func repeatTypeChanged() {
        viewModel.updateRepeatCycle(repeatSegmentedControl.selectedSegmentIndex)
    }
    
    @objc private func timeSwitchChanged() {
        timePicker.isHidden = !timeSwitch.isOn
        viewModel.updateHasTimeAlert(timeSwitch.isOn)
    }
    
    @objc private func timeChanged() {
        viewModel.updateTime(timePicker.date)
    }
    
    @objc private func notificationChanged() {
        viewModel.updateHasNotification(notificationSwitch.isOn)
    }
    
    @objc private func addDetailButtonTapped() {
        // TODO: 상세 비용 추가 화면으로 이동하는 로직 구현 해야됨여기
        print("상세 비용 추가하기 버튼이 탭됨.")
    }
    
    @objc private func saveButtonTapped() {
        viewModel.save { [weak self] result in
            switch result {
            case .success:
                self?.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print("Error saving management: \(error)")
            }
        }
    }
}
