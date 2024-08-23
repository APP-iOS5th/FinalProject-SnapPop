//
//  AddManagementViewController.swift
//  SnapPop
//
//  Created by 장예진 on 8/8/24.
//

import Combine
import UIKit

class AddManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationCellDelegate {
    private let viewModel: AddManagementViewModel
    private var cancellables = Set<AnyCancellable>()
    private var isTimePickerVisible = false
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let addDetailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("상세 비용 추가하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.customButtonColor
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addDetailButtonTapped), for: .touchUpInside)
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
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(addDetailButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let cells: [(AnyClass, String)] = [
            (TitleCell.self, "TitleCell"),
            (MemoCell.self, "MemoCell"),
            (ColorCell.self, "ColorCell"),
            (DateCell.self, "DateCell"),
            (NotificationCell.self, "NotificationCell"),
            (RepeatCell.self, "RepeatCell"),
            (TimeCell.self, "TimeCell")
        ]
        
        for (cellClass, identifier) in cells {
            tableView.register(cellClass, forCellReuseIdentifier: identifier)
        }
        
        setupConstraints()
        
        title = "새로운 자기 관리"
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        cancelButton.tintColor = .systemBlue
        let saveButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = .systemBlue
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addDetailButton.topAnchor, constant: -10),

            addDetailButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addDetailButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addDetailButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addDetailButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func bindViewModel() {
        // 기존 바인딩 로직들
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
        
        bind(viewModel.$startDate) { [weak self] date in
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DateCell {
                cell.configure(with: date)
            }
        }
        
        bind(viewModel.$alertStatus) { [weak self] alertStatus in
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 1, section: 2)) as? NotificationCell {
                cell.switchControl.isOn = alertStatus
            }
        }

        // saveButton 활성화 상태 바인딩
        viewModel.isValid
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: navigationItem.rightBarButtonItem!)
            .store(in: &cancellables)
    }
    
    @objc private func cancelButtonTapped() {
        // HomeViewController로 돌아가기
        navigationController?.popViewController(animated: true)
    }

    @objc private func saveButtonTapped() {
        viewModel.save { [weak self] result in
            switch result {
            case .success:
                self?.navigationController?.popViewController(animated: true)
            case .failure(let error):
                let alert = UIAlertController(title: "오류", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }
        }
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
        viewModel.startDate = sender.date
    }
    
    func notificationCellDidToggle(_ cell: NotificationCell, isOn: Bool) {
        viewModel.alertStatus = isOn
        isTimePickerVisible = isOn
        
        UIView.animate(withDuration: 0.3) {
            self.tableView.beginUpdates()
            if isOn {
                self.tableView.insertRows(at: [IndexPath(row: 1, section: 2)], with: .fade)
            } else {
                self.tableView.deleteRows(at: [IndexPath(row: 1, section: 2)], with: .fade)
            }
            self.tableView.endUpdates()
        }
        
        if isOn {
            viewModel.alertTime = Date()
        }
    }

     @objc private func timeChanged(_ sender: UIDatePicker) {
         viewModel.alertTime = sender.date
     }
    
    @objc private func addDetailButtonTapped() {
        let detailCostViewModel = DetailCostViewModel()
        let detailCostVC = DetailCostViewController(viewModel: detailCostViewModel)
        detailCostVC.modalPresentationStyle = .formSheet
        present(detailCostVC, animated: true, completion: nil)
    }
    
    private func bind<T>(_ publisher: Published<T>.Publisher, to update: @escaping (T) -> Void) {
        publisher
            .sink { [weak self] value in
                update(value)
            }
            .store(in: &cancellables)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3 // 제목, 색상, 메모
        case 1:
            return 2 // 날짜, 반복
        case 2:
            return isTimePickerVisible ? 2 : 1 // 알림
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
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as? DateCell else {
                    return UITableViewCell()
                }
                cell.configure(with: viewModel.startDate)
                cell.datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
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
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as? NotificationCell else { return UITableViewCell() }
                cell.textLabel?.text = "알림"
                cell.switchControl.isOn = viewModel.alertStatus
                cell.delegate = self
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCell", for: indexPath) as? TimeCell else { return UITableViewCell() }
                cell.timePicker.date = viewModel.alertTime
                cell.timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
}
