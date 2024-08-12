//
//  AddManagementViewController.swift
//  SnapPop
//
//  Created by 장예진 on 8/8/24.
//

import UIKit

class AddManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: AddManagementViewModel

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.isHidden = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let repeatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("반복 주기 선택", for: .normal)
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
        setupRepeatButtonMenu()
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(tableView)
        view.addSubview(timePicker)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        setupConstraints()

        title = "새로운 자기 관리"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(saveButtonTapped))
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: timePicker.topAnchor),

            timePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timePicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupRepeatButtonMenu() {
        var actions: [UIAction] = []

        for (index, option) in viewModel.repeatOptions.enumerated() {
            let action = UIAction(title: option) { [weak self] _ in
                self?.viewModel.updateRepeatCycle(index)
                self?.repeatButton.setTitle(option, for: .normal)
            }
            actions.append(action)
        }

        repeatButton.menu = UIMenu(title: "반복 주기 선택", children: actions)
        repeatButton.showsMenuAsPrimaryAction = true
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8 //  제목, 메모, 색상, 날짜, 반복, 시간, 알림, 상세 비용 추가 (8개임총)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "제목"
            let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            textField.placeholder = "제목 입력"
            textField.addTarget(self, action: #selector(titleChanged(_:)), for: .editingChanged)
            cell.accessoryView = textField
        case 1:
            cell.textLabel?.text = "메모"
            let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            textField.placeholder = "메모 입력"
            textField.addTarget(self, action: #selector(memoChanged(_:)), for: .editingChanged)
            cell.accessoryView = textField
        case 2:
            cell.textLabel?.text = "색상"
            let colorPicker = UIColorWell(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            colorPicker.supportsAlpha = false
            colorPicker.addTarget(self, action: #selector(colorChanged(_:)), for: .valueChanged)
            cell.accessoryView = colorPicker
        case 3:
            cell.textLabel?.text = "날짜"
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            cell.accessoryView = datePicker
        case 4:
            cell.textLabel?.text = "반복"
            cell.accessoryView = repeatButton
        case 5:
            cell.textLabel?.text = "시간"
            let switchControl = UISwitch()
            switchControl.addTarget(self, action: #selector(timeSwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchControl
        case 6:
            cell.textLabel?.text = "알림"
            let switchControl = UISwitch()
            switchControl.addTarget(self, action: #selector(notificationChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchControl
        case 7:
            cell.textLabel?.text = "상세 비용 추가하기 +"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemBlue
        default:
            break
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 7 {
            addDetailButtonTapped()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Actions

    @objc private func titleChanged(_ sender: UITextField) {
        viewModel.updateTitle(sender.text ?? "")
    }

    @objc private func memoChanged(_ sender: UITextField) {
        viewModel.updateMemo(sender.text ?? "")
    }

    @objc private func colorChanged(_ sender: UIColorWell) {
        viewModel.updateColor(sender.selectedColor ?? .black)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        viewModel.updateDate(sender.date)
    }

    @objc private func timeSwitchChanged(_ sender: UISwitch) {
        timePicker.isHidden = !sender.isOn
        viewModel.updateHasTimeAlert(sender.isOn)
    }

    @objc private func notificationChanged(_ sender: UISwitch) {
        viewModel.updateHasNotification(sender.isOn)
    }

    @objc private func addDetailButtonTapped() {
        // TODO: 상세 비용 추가 화면으로 이동하는 로직 구현
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
