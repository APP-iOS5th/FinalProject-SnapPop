//
//  CategorySettingsViewController.swift
//  SnapPop
//
//  Created by 정종원 on 8/19/24.
//

import UIKit

class CategorySettingsViewController: UIViewController {
    
    //MARK: - Properties
    var viewModel: CustomNavigationBarViewModelProtocol
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리 설정"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "카테고리를 입력해 주세요."
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.leftView = leftPadding
        textField.backgroundColor = .customBackground
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.customToggle.cgColor
        textField.layer.borderWidth = 1
        textField.keyboardType = .namePhonePad
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var addCategoryButton: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.title = "추가"
        buttonConfig.baseBackgroundColor = UIColor.customButtonColor
        buttonConfig.baseForegroundColor = .black
        buttonConfig.background.cornerRadius = 8
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var categoryTable: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .customBackground
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategorySettingsTableViewCell.self,
                           forCellReuseIdentifier: CategorySettingsTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Initializers
    init(viewModel: CustomNavigationBarViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBackground
        setupLayout()
        hideKeyboardWhenTappedAround()
        viewModel.categoryisUpdated?()
        print("CategorySettingsViewController의 viewModel 주소: \(Unmanaged.passUnretained(self.viewModel as AnyObject).toOpaque())")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.categoryisUpdated?()
    }
    
    // MARK: - Methods
    private func setupLayout() {
        view.addSubviews([
            titleLabel,
            categoryTextField,
            addCategoryButton,
            categoryTable
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            categoryTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            categoryTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            categoryTextField.heightAnchor.constraint(equalTo: addCategoryButton.heightAnchor),
            
            addCategoryButton.centerYAnchor.constraint(equalTo: categoryTextField.centerYAnchor),
            addCategoryButton.leadingAnchor.constraint(equalTo: categoryTextField.trailingAnchor, constant: 10),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.widthAnchor.constraint(equalToConstant: 60),
            
            categoryTextField.trailingAnchor.constraint(equalTo: addCategoryButton.leadingAnchor, constant: -10),
            
            categoryTable.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: 20),
            categoryTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Methods
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let keyboardHeight = keyboardSize.height
            let safeAreaBottomInset = view.safeAreaInsets.bottom
            
            // 키보드 위와 categoryTextField 남은 공간
            let categoryTextFieldBottom = categoryTextField.frame.origin.y + categoryTextField.frame.size.height
            let spaceAboveKeyboard = view.frame.size.height - keyboardHeight - safeAreaBottomInset
            
            // categoryTextField이 키보드 위에 있는지 확인 후, 필요한 만큼 화면 이동
            if categoryTextFieldBottom > spaceAboveKeyboard {
                view.frame.origin.y = -(categoryTextFieldBottom - spaceAboveKeyboard + 10)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    // MARK: - Actions
    @objc func addCategoryButtonTapped() {
        guard let categoryName = categoryTextField.text else { return }
        // 텍스트 필드에 입력이 있는 경우
        if !(categoryName.isEmpty) {
            // 카테고리가 없는 경우
            if viewModel.categories.isEmpty {
                let newCategory = Category(userId: "\(AuthViewModel.shared.currentUser?.uid ?? "")", title: "\(categoryName)", alertStatus: true)
                viewModel.saveCategory(category: newCategory) {
                    DispatchQueue.main.async {
                        self.categoryTable.reloadData()
                    }
                    self.viewModel.selectCategory(at: 0)
                    self.viewModel.categoryisUpdated?()
                }
                categoryTextField.text = ""
            } else {
                // 카테고리가 있는 경우
                let newCategory = Category(userId: "\(AuthViewModel.shared.currentUser?.uid ?? "")", title: "\(categoryName)", alertStatus: true)
                viewModel.saveCategory(category: newCategory) {
                    DispatchQueue.main.async {
                        self.categoryTable.reloadData()
                    }
                }
                categoryTextField.text = ""
            }
            
        } else {
            // 텍스트 필드에 입력이 없는 경우
            // TODO: - TextField에 입력을 하지 않았을때
        }
        
    }
}

// MARK: - UITableViewDelegate, DataSource Methods
extension CategorySettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategorySettingsTableViewCell.identifier, for: indexPath) as? CategorySettingsTableViewCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.categories[indexPath.row]
        cell.categoryNameLabel.text = category.title
        
        if category.alertStatus {
            cell.notificationButton.setImage(UIImage(systemName: "bell"), for: .normal)
        } else {
            cell.notificationButton.setImage(UIImage(systemName: "bell.slash"), for: .normal)
        }
        
        // cell의 "checkmark" 버튼을 눌렀을때 실행되는 클로저
        cell.saveEditButtonTapped = { [weak self] newName in
            guard let self = self else { return }
            var updatedCategory = self.viewModel.categories[indexPath.row]
            updatedCategory.title = newName
            self.viewModel.updateCategory(categoryId: updatedCategory.id!, category: updatedCategory) {
                self.viewModel.categories[indexPath.row] = updatedCategory
                DispatchQueue.main.async {
                    self.categoryTable.reloadRows(at: [indexPath], with: .none)
                }
                if updatedCategory.id == self.viewModel.currentCategory?.id {
                    self.viewModel.currentCategory?.title = newName
                    self.viewModel.categoryisUpdated?()
                }
            }
        }
        
        // cell의 "bell" 버튼을 눌렀을때 실행되는 클로저
        cell.notificationButtonTapped = { [weak self] in
            guard let self = self else { return }
            let index = indexPath.row
            self.viewModel.categories[index].alertStatus.toggle()
            
            let alertStatusImage = self.viewModel.categories[index].alertStatus ? "bell" : "bell.slash"
            cell.notificationButton.setImage(UIImage(systemName: alertStatusImage), for: .normal)
            
            let updatedCategory = self.viewModel.categories[index]
            self.viewModel.updateCategory(categoryId: updatedCategory.id!, category: updatedCategory) {
                DispatchQueue.main.async {
                    self.categoryTable.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = .customBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let trash = UIContextualAction(style: .normal, title: "") { (_, _, success: @escaping (Bool) -> Void) in
            self.viewModel.deleteCategory(at: indexPath.row) { newTitle in
                guard let newTitle = newTitle else { return }
                DispatchQueue.main.async {
                    self.categoryTable.reloadData()
                }
                print("CategorySettingsViewController에서 categoryisUpdated 클로저 호출 직전")
                self.viewModel.categoryisUpdated?()
            }
            
            print("Current Categories: \(self.viewModel.categories)")
            print("현재 선택된 카테고리: \(self.viewModel.currentCategory?.title)")
            
            success(true)
            
        }
        trash.backgroundColor = .red
        trash.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [trash])
    }
}

// MARK: - UITextFieldDelegate Methods
extension CategorySettingsViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        return true
    }
}
