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
        // TODO: - uid 삭제해야함
        guard let categoryName = categoryTextField.text else { return }
        if !(categoryName.isEmpty)  {
            var newCategory = Category(userId: "\(AuthViewModel.shared.currentUser?.uid ?? "")", title: "\(categoryName)", alertStatus: true)
            viewModel.saveCategory(category: newCategory) {
                DispatchQueue.main.async {
                    self.categoryTable.reloadData()
                }
            }
            categoryTextField.text = ""
        } else {
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
        cell.selectionStyle = .none
        cell.backgroundColor = .customBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notification = UIContextualAction(style: .normal, title: "") { (_, _, success: @escaping (Bool) -> Void) in
            // TODO: - ViewModel 사용하여 파이어베이스에 알림 추가/ 분기해야함
            success(true)
        }
        notification.backgroundColor = .systemGray4
        notification.image = UIImage(systemName: "bell")
        
        let trash = UIContextualAction(style: .normal, title: "") { (_, _, success: @escaping (Bool) -> Void) in
            self.viewModel.deleteCategory(at: indexPath.row) {
                self.viewModel.loadCategories {
                    DispatchQueue.main.async {
                        self.categoryTable.reloadData()
                    }
                }
            }
            DispatchQueue.main.async {
                self.categoryTable.reloadData()
            }
            print("Current Categories: \(self.viewModel.categories)")
            success(true)
        }
        trash.backgroundColor = .red
        trash.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions:[notification, trash])
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
