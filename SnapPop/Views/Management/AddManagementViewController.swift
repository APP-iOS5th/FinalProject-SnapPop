//
//  AddManagementViewController.swift
//  SnapPop
//
//  Created by 장예진 on 8/8/24.
//

import Combine
import UIKit

class AddManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: AddManagementViewModel
    private var cancellables = Set<AnyCancellable>()
    
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
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(timePicker)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let cells: [(AnyClass, String)] = [
            (TitleCell.self, "TitleCell"),
            (MemoCell.self, "MemoCell"),
            (ColorCell.self, "ColorCell"),
            (DateCell.self, "DateCell"),
            (NotificationCell.self, "NotificationCell"),
            (RepeatCell.self, "RepeatCell")
        ]
        
        for (cellClass, identifier) in cells {
            tableView.register(cellClass, forCellReuseIdentifier: identifier)
        }
        
        setupConstraints()
        
        title = "새로운 자기 관리"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
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
    
    private func bind<T>(_ publisher: Published<T>.Publisher, to update: @escaping (T) -> Void) {
        publisher
            .sink { [weak self] value in
                update(value)
            }
            .store(in: &cancellables)
    }
    
    private func bindViewModel() {
        bind(viewModel.$title) { [weak self] title in
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TitleCell {
                cell.textField.text = title
            }
        }
        
        bind(viewModel.$memo) { [weak self] memo in
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? MemoCell {
                cell.textField.text = memo
            }
        }
        
        bind(viewModel.$color) { [weak self] color in
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ColorCell {
                cell.colorPicker.selectedColor = color
            }
        }
        
        bind(viewModel.$createdAt) { [weak self] date in
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DateCell {
                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy.MM.dd"
//                dateFormatter.locale = Locale(identifier: "ko_KR") // 로케일 설정 추가
                let formattedDate = dateFormatter.string(from: date)
                cell.datePicker.date = date
                cell.textLabel?.text = "날짜"
                cell.detailTextLabel?.text = formattedDate
                cell.imageView?.tintColor = .black
            }
        }
        
        bind(viewModel.$hasTimeAlert) { [weak self] hasTimeAlert in
            self?.timePicker.isHidden = !hasTimeAlert
        }
        
        bind(viewModel.$hasNotification) { [weak self] hasNotification in
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 1, section: 2)) as? NotificationCell {
                cell.switchControl.isOn = hasNotification
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // 네 번째 섹션 추가
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3 // 제목, 색상, 메모
        case 1:
            return 2 // 날짜, 반복
        case 2:
            return 2 // 시간, 알림
        case 3:
            return 1 // 상세 비용 추가하기 버튼
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as? TitleCell else { return UITableViewCell() }
                cell.textField.text = viewModel.title
                cell.textField.addTarget(self, action: #selector(titleChanged(_:)), for: .editingChanged)
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as? ColorCell else { return UITableViewCell() }
                cell.textLabel?.text = "색상"
                cell.colorPicker.selectedColor = viewModel.color
                cell.colorPicker.addTarget(self, action: #selector(colorChanged(_:)), for: .valueChanged)
                return cell
            case 2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell", for: indexPath) as? MemoCell else { return UITableViewCell() }
                cell.textField.text = viewModel.memo
                cell.textField.addTarget(self, action: #selector(memoChanged(_:)), for: .editingChanged)
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as? DateCell else { return UITableViewCell() }
                cell.textLabel?.text = "날짜"
                cell.datePicker.date = viewModel.createdAt
                cell.datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
                cell.imageView?.image = UIImage(systemName: "calendar")
                cell.imageView?.tintColor = .black
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatCell", for: indexPath) as? RepeatCell else { return UITableViewCell() }
                cell.textLabel?.text = "반복"
                cell.configure(with: viewModel)
                return cell
            default:
                return UITableViewCell()
            }
        case 2:
            switch indexPath.row {
            case 0:
                let cell = UITableViewCell()
                cell.textLabel?.text = "시간"
                let switchControl = UISwitch()
                switchControl.isOn = viewModel.hasTimeAlert
                switchControl.addTarget(self, action: #selector(timeSwitchChanged(_:)), for: .valueChanged)
                cell.accessoryView = switchControl
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as? NotificationCell else { return UITableViewCell() }
                cell.textLabel?.text = "알림"
                cell.switchControl.isOn = viewModel.hasNotification
                cell.switchControl.addTarget(self, action: #selector(notificationChanged(_:)), for: .valueChanged)
                return cell
            default:
                return UITableViewCell()
            }
        case 3:
            let cell = UITableViewCell()
            cell.textLabel?.text = "상세 비용 추가하기"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemBlue
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let baseCell = cell as? BaseTableViewCell else { return }

        let cornerRadius: CGFloat = 10.0
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)

        if numberOfRows == 1 {
            // 섹션에 셀이 하나만 있을 때
            baseCell.setCornerRadius(corners: [.allCorners], radius: cornerRadius)
        } else if indexPath.row == 0 {
            // 첫 번째 셀일 때
            baseCell.setCornerRadius(corners: [.topLeft, .topRight], radius: cornerRadius)
        } else if indexPath.row == numberOfRows - 1 {
            // 마지막 셀일 때
            baseCell.setCornerRadius(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
        } else {
            // 중간 셀은 코너를 둥글게 하지 않음
            baseCell.setCornerRadius(corners: [], radius: 0)
        }

        baseCell.layer.masksToBounds = true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            addDetailButtonTapped()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        // HomeViewController로 돌아가기
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func titleChanged(_ sender: UITextField) {
        viewModel.title = sender.text ?? ""
    }
    
    @objc private func memoChanged(_ sender: UITextField) {
        viewModel.memo = sender.text ?? ""
    }
    
    @objc private func colorChanged(_ sender: UIColorWell) {
        viewModel.color = sender.selectedColor ?? .black
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        viewModel.createdAt = sender.date
    }
    
    @objc private func timeSwitchChanged(_ sender: UISwitch) {
        viewModel.hasTimeAlert = sender.isOn
    }
    
    @objc private func notificationChanged(_ sender: UISwitch) {
        viewModel.hasNotification = sender.isOn
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
