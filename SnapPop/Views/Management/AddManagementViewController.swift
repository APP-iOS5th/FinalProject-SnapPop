//
//  AddManagementViewController.swift
//  SnapPop
//
//  Created by 장예진 on 8/8/24.
//

import Combine
import UIKit

class AddManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationCellDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    private let viewModel: AddManagementViewModel
    var homeViewModel: HomeViewModel?
    var onSave: ((Management) -> Void)? 
    var selectedDate = Date()
    private var cancellables = Set<AnyCancellable>()
    private var isTimePickerVisible = false
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("등록 완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.customButtonColor
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    init(viewModel: AddManagementViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupTapGesture()
        
        if !viewModel.edit {
            viewModel.startDate = self.selectedDate // 수정시에 management.startDate를 selectedDate가 업데이트해버려서 처음 등록시에만 실행되게 변경
        }
        // 알림 다시 꺼도 앱 안터지게
        isTimePickerVisible = viewModel.alertStatus

        // NotificationCenter를 사용하게 변경
        NotificationCenter.default.addObserver(self, selector: #selector(categoryDidChangeNotification(_:)), name: .categoryDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(managementSavedNotification(_:)), name: .managementSavedNotification, object: nil)

        if let navigationController = self.navigationController as? CustomNavigationBarController,
           let delegate = viewModel as? CategoryChangeDelegate {
            navigationController.viewModel.delegate = delegate
        }

        print(UserDefaults.standard.dictionaryRepresentation())
        viewModel.categoryDidChange(to: UserDefaults.standard.string(forKey: "currentCategoryId") ?? "default")
        // 네비게이션 타이틀 설정
        if viewModel.edit {
            title = "관리 수정"
            saveButton.setTitle("수정 완료", for: .normal)
        } else {
            title = "새로운 관리"
            saveButton.setTitle("등록 완료", for: .normal)
        }
        setupLeftBarButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        enableInteractivePopGesture()
    }
    
    // NotificationCenter에서 사용할 메서드
    @objc private func categoryDidChangeNotification(_ notification: Notification) {
        if let newCategoryId = notification.userInfo?["newCategoryId"] as? String {
            // 카테고리 ID를 ViewModel에 전달
            viewModel.categoryId = newCategoryId
        }
    }
    
    @objc private func managementSavedNotification(_ notification: Notification) {
        print("Management가 저장되었습니다.")
    }
    
    deinit {
        // deinit에서 observer 제거
        NotificationCenter.default.removeObserver(self)
    }

    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .customBackgroundColor
        
        // 테이블뷰와 버튼들
        view.addSubview(tableView)
        view.addSubview(saveButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let cells: [(AnyClass, String)] = [
            (TitleCell.self, "TitleCell"),
            (MemoCell.self, "MemoCell"),
            (ColorCell.self, "ColorCell"),
            (DateCell.self, "DateCell"),
            (NotificationCell.self, "NotificationCell"),
            (RepeatCell.self, "RepeatCell"),
            (TimeCell.self, "TimeCell"),
            (DetailCostCell.self, "DetailCostCell")
        ]
        
        for (cellClass, identifier) in cells {
            tableView.register(cellClass, forCellReuseIdentifier: identifier)
        }
        
        // 제약 조건 설정
        setupConstraints()
    }
    
    // MARK: - Constraints Setup
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions    
    @objc private func saveButtonTapped() {
        viewModel.saveOrUpdate { [weak self] result in
            switch result {
            case .success:
                if let management = self?.viewModel.management {
                    self?.onSave?(management)  // 변경된 저장 항목을 저장
                }
                self?.navigationController?.popViewController(animated: true)
            case .failure(let error):
                let alert = UIAlertController(title: "오류", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    
    @objc private func titleChanged(_ sender: UITextField) {
        // 타이틀 텍스트 필드 값 변경 시 ViewModel에 반영
        viewModel.title = sender.text ?? ""
    }
    
    @objc private func memoChanged(_ sender: UITextField) {
        // 메모 텍스트 필드 값 변경 시 ViewModel에 반영
        viewModel.memo = sender.text ?? ""
    }
    
    @objc private func colorChanged(_ sender: UIColorWell) {
        // 색상 선택기 값 변경 시 ViewModel에 반영
        viewModel.color = sender.selectedColor ?? .black
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        // 날짜 선택기 값 변경 시 ViewModel에 반영
        viewModel.startDate = sender.date
    }
    
    // NotificationCellDelegate 메서드 - 알림 스위치 토글 시 호출
    func notificationCellDidToggle(_ cell: NotificationCell, isOn: Bool) {
        viewModel.alertStatus = isOn
        let indexPath = IndexPath(row: 1, section: 2) // 타임 피커 행의 IndexPath
        tableView.beginUpdates()
        
        if isOn {
            if !isTimePickerVisible {
                isTimePickerVisible = true
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        } else {
            if isTimePickerVisible {
                isTimePickerVisible = false
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        
        tableView.endUpdates()

        if isOn {
            viewModel.alertTime = Date()
        }
    }

    @objc private func timeChanged(_ sender: UIDatePicker) {
        // 시간 선택기 값 변경 시 ViewModel에 반영
        viewModel.alertTime = sender.date
    }
    
    @objc private func addDetailButtonTapped() {
        // 상세 내역 추가 버튼 탭 시, DetailCostViewController를 모달로 표시
        let detailCostVC = DetailCostViewController()
        detailCostVC.delegate = self
        let navController = UINavigationController(rootViewController: detailCostVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: - Binding Helper
    // ViewModel의 Publisher를 UI 업데이트와 바인딩
    private func bind<T>(_ publisher: Published<T>.Publisher, to update: @escaping (T) -> Void) {
        publisher
            .sink { [weak self] value in
                update(value)
            }
            .store(in: &cancellables)
    }
    
    private func bindViewModel() {
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)
                .compactMap { $0.object as? UITextField }
                .sink { [weak self] textField in
                    if let cell = textField.superview?.superview as? TitleCell {
                        self?.viewModel.title = textField.text ?? ""
                    } else if let cell = textField.superview?.superview as? MemoCell {
                        self?.viewModel.memo = textField.text ?? ""
                    }
                }
                .store(in: &cancellables)
        
        bind(viewModel.$title) { [weak self] title in
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TitleCell {
                cell.textField.text = title
                cell.textField.autocorrectionType = .no
                cell.textField.spellCheckingType = .no
            }
        }

        bind(viewModel.$memo) { [weak self] memo in
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? MemoCell {
                cell.textField.text = memo
                cell.textField.autocorrectionType = .no
                cell.textField.spellCheckingType = .no
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
        bind(viewModel.$repeatCycle) { [weak self] cycle in
            guard let self = self else { return }
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? RepeatCell {
                cell.configure(with: self.viewModel)
            }
        }
     
        bind(viewModel.$alertStatus) { [weak self] hasNotification in
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 1, section: 2)) as? NotificationCell {
                cell.switchControl.isOn = hasNotification
            }
        }
        
        // bind함수에 receive(on: DispatchQueue.main)를 넣으니 화면이 이상하게 업데이트됨
        viewModel.$detailCostArray
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3 // 제목, 색상, 메모
        case 1:
            return 2 // 날짜, 반복
        case 2:
            return isTimePickerVisible ? 2 : 1 // 알림
        case 3:
            return viewModel.detailCostArray.count
        default:
            return 0
        }
    }
    
    // 섹션 별 소제목
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "기본 정보"
        case 1:
            return "스케줄 설정"
        case 2:
            return "알림"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        
        let titleLabel = UILabel()
        let screenWidth = UIScreen.main.bounds.width
        
        titleLabel.text = "상세내역 및 비용 추가"
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        titleLabel.textColor = .gray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let addButton = UIButton(type: .system)
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .light)
        addButton.setTitleColor(UIColor.dynamicTextColor, for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addDetailButtonTapped), for: .touchUpInside)
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(addButton)
        
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.contentView.leadingAnchor, constant: leadingConstant(for: screenWidth)),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -8),
            addButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
        ])
        
        switch section {
        case 3:
            return headerView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 3:
            return 44
        default:
            return UITableView.automaticDimension
        }
    }
    
    func leadingConstant(for width: CGFloat) -> CGFloat {
        switch width {
        case 0..<375:
            return 16 // 예: iPhone SE, iPhone 8
        case 375..<414:
            return 18 // 예: iPhone 11, iPhone 12 Mini
        case 414..<768:
            return 20 // 예: iPhone 12 Pro Max, iPhone 13 Pro Max
        case 768..<1024:
            return 24 // 예: iPad Mini
        case 1024..<1366:
            return 28 // 예: iPad Pro 11인치
        default:
            return 32 // 예: iPad Pro 12.9인치 이상
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
                cell.textField.delegate = self
                cell.textField.autocorrectionType = .no
                cell.textField.spellCheckingType = .no
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as? ColorCell else { return UITableViewCell() }
                cell.colorPicker.selectedColor = viewModel.color
                cell.colorPicker.addTarget(self, action: #selector(colorChanged(_:)), for: .valueChanged)
                return cell
            case 2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell", for: indexPath) as? MemoCell else { return UITableViewCell() }
                cell.textField.text = viewModel.memo
                cell.textField.addTarget(self, action: #selector(memoChanged(_:)), for: .editingChanged)
                cell.textField.delegate = self
                cell.textField.autocorrectionType = .no
                cell.textField.spellCheckingType = .no
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
                cell.dateChangedHandler = { [weak self] newDate in
                    self?.viewModel.startDate = newDate
                    print("ViewModel startDate updated to: \(newDate)")
                }
                cell.dismissHandler = { [weak self] in
                    self?.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatCell", for: indexPath) as? RepeatCell else { return UITableViewCell() }
                cell.configure(with: viewModel)
                return cell
            default:
                return UITableViewCell()
            }
        case 2:
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as? NotificationCell else { return UITableViewCell() }
                cell.switchControl.isOn = viewModel.alertStatus
                cell.delegate = self
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCell", for: indexPath) as? TimeCell else { return UITableViewCell() }
                cell.timePicker.date = viewModel.alertTime
                cell.timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
                return cell
            }
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCostCell", for: indexPath) as? DetailCostCell else { return UITableViewCell() }
            cell.configure(with: viewModel.detailCostArray[indexPath.row])
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    // 상세내역 스와이프 삭제
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 3 else {
            return nil // 다른 섹션에 대해서는 스와이프 동작을 비활성화
        }

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }

            self.viewModel.detailCostArray.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .automatic)
            if self.viewModel.detailCostArray.isEmpty {
                tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
            }

            completionHandler(true)
        }

        deleteAction.image = UIImage(systemName: "trash")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           if section == 1 {
               return 30 // footer의 높이
           }
           return 0 // 다른 섹션은 footer 없음
       }

       // 섹션 footer 뷰 반환
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
           if section == 1 {
               let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
               footerView.backgroundColor = .clear

               let label = UILabel()
               label.text = "반복은 6개월까지 저장됩니다"
               label.textAlignment = .right
               label.textColor = .gray
               label.font = UIFont.systemFont(ofSize: 12)
               label.translatesAutoresizingMaskIntoConstraints = false

               footerView.addSubview(label)

               NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
                label.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
               ])

               return footerView
           }
           return nil
       }

    
// MARK: - Keyboard Handling

    // 화면을 터치했을 때 키보드 내리기
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // Return 키를 눌렀을 때 키보드 내리기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddManagementViewController: DetailCostViewControllerDelegate {
    func addDetailCost(data detailCost: DetailCost) {
        viewModel.detailCostArray.append(detailCost)
    }
}
