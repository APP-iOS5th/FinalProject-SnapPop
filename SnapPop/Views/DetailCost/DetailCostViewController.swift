//
//  DetailCostViewController.swift
//  SnapPop
//
//  Created by 이인호 on 8/19/24.
//
//
import UIKit

protocol DetailCostViewControllerDelegate: AnyObject {
    func addDetailCost(data detailCost: DetailCost)
}

class DetailCostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - Properties
    private var isOpen = false // 금액 계산 셀 열기 위한 변수
    private var titleText: String = ""
    private var descriptionText: String?
    private var oneTimeCost: Int?
    
    // 상세 내역 정보를 관리 등록 뷰로 전달하기 위한 Delegate
    var delegate: DetailCostViewControllerDelegate?
    
    // MARK: - UIComponents
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        return tableView
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupKeyboardEvent()
        setupTapGesture()
    }
    
    // MARK: - Methods
    func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        let cells: [(AnyClass, String)] = [
            (TitleCell2.self, TitleCell2.identifier),
            (DescriptionCell.self, DescriptionCell.identifier),
            (AddCostCell.self, AddCostCell.identifier),
            (OneTimeCostCell.self, OneTimeCostCell.identifier),
            (CalculateCostCell.self, CalculateCostCell.identifier)
        ]
        
        for (cellClass, identifier) in cells {
            tableView.register(cellClass, forCellReuseIdentifier: identifier)
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        title = "상세내역"
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .customBackgroundColor
        appearance.backgroundEffect = nil
        appearance.shadowColor = nil
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "추가", style: .done, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        if !titleText.isEmpty {
            // DetailCost 객체 생성 (oneTimeCost는 옵셔널)
            let detailCost = DetailCost(title: titleText, description: descriptionText, oneTimeCost: oneTimeCost)
            // 데이터 전달
            delegate?.addDetailCost(data: detailCost)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return isOpen ? 2 : 1
        case 2:
            return isOpen ? 1 : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "상세 정보"
        case 1:
            return "비용"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleCell2.identifier, for: indexPath) as? TitleCell2 else { return UITableViewCell() }
                cell.textField.delegate = self
                cell.textField.autocorrectionType = .no
                cell.textField.autocapitalizationType = .none
                cell.textField.spellCheckingType = .no
                cell.textField.text = titleText
                cell.textField.tag = 1
                cell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DescriptionCell.identifier, for: indexPath) as? DescriptionCell else { return UITableViewCell() }
                cell.textField.delegate = self
                cell.textField.autocorrectionType = .no
                cell.textField.autocapitalizationType = .none
                cell.textField.spellCheckingType = .no
                cell.textField.text = descriptionText
                cell.textField.tag = 2
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: AddCostCell.identifier, for: indexPath) as? AddCostCell else { return UITableViewCell() }
                cell.toggleSwitch.isOn = self.isOpen
                
                cell.onToggleSwitchChanged = { [weak self] isOn in
                    guard let self = self else { return }
                    self.isOpen = isOn
                    self.tableView.reloadSections([1, 2], with: .automatic)
                }
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: OneTimeCostCell.identifier, for: indexPath) as? OneTimeCostCell else { return UITableViewCell() }
                return cell
            default:
                return UITableViewCell()
            }
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CalculateCostCell.identifier, for: indexPath) as? CalculateCostCell else { return UITableViewCell() }
            cell.onCalculate = { [weak self] result in
                guard let self = self else { return }
                self.oneTimeCost = result
                guard let oneTimeCostCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? OneTimeCostCell else { return }
                oneTimeCostCell.updateCost(with: result)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    // MARK: - Keyboard Handling

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
    // 유효성 검사 및 텍스트 누락 방지
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == 1 {
            titleText = textField.text ?? ""
            updateSaveButtonState()
        }
    }

    private func updateSaveButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = !titleText.isEmpty
    }
    
    // 키보드 올라왔을때
    @objc func keyboardWillShow(_ sender: Notification) {
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentResponder as? UITextField else { return }
        
        // Y축으로 키보드의 상단 위치
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        // 현재 선택한 텍스트 필드의 Frame 값
        let convertedTextFieldFrame = view.convert(currentTextField.frame,
                                                   from: currentTextField.superview)
        // Y축으로 현재 텍스트 필드의 하단 위치
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        // Y축으로 텍스트필드 하단 위치가 키보드 상단 위치보다 클 때 (텍스트필드가 키보드에 가려질 때)
        if textFieldBottomY > keyboardTopY {
            let textFieldTopY = convertedTextFieldFrame.origin.y
            let newFrame = (textFieldTopY - keyboardTopY / 1.6) * -1
            view.frame.origin.y = newFrame
        }
    }
    
    // 키보드 내려갔을때
    @objc func keyboardWillHide(_ sender: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}
