//
//  CustomNavigationBarController.swift
//  SnapPop
//
//  Created by 정종원 on 8/19/24.
//

import UIKit

class CustomNavigationBarController: UINavigationController {
    
    // MARK: - Properties
    var viewModel: CustomNavigationBarViewModelProtocol
    
    // MARK: - UI Components
    lazy var categoryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = !viewModel.categories.isEmpty ? "" : "카테고리를 추가해주세요"
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 10
        config.baseForegroundColor = .black
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.menu = self.createCategoryMenu(categories: viewModel.categories)
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .menuActionTriggered)
        button.showsMenuAsPrimaryAction = true
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializers
    init(viewModel: CustomNavigationBarViewModelProtocol, rootViewController: UIViewController) {
        self.viewModel = viewModel
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("유저 디폴트에 저장된 id: \(String(describing: UserDefaults.standard.string(forKey: "currentCategoryId")))")
        setupCustomNavigationBar()
        updateCategoryTitle()
        viewModel.categoryisUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateCategoryMenu()
            }
        }
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if topViewController?.navigationItem.leftBarButtonItem == nil {
            setupNavigationBarItems()
        }
        updateCategoryTitle()
        updateCategoryMenu()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateCategoryMenu()
    }
    
    // MARK: - Methods
    private func setupCustomNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20.0),
                                          .foregroundColor: UIColor.black]
        
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .black
    }
    
    private func setupNavigationBarItems() {
        let menuButtonItem = UIBarButtonItem(customView: categoryButton)
        
        let bellButton = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(bellButtonTapped))
        let gearButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(gearButtonTapped))
        
        topViewController?.navigationItem.leftBarButtonItem = menuButtonItem
        topViewController?.navigationItem.rightBarButtonItems = [gearButton, bellButton]
        
        view.addSubview(categoryButton)
        NSLayoutConstraint.activate([
            categoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            categoryButton.heightAnchor.constraint(equalToConstant: 44)
            
        ])
    }
    
    private func createCategoryMenu(categories: [Category]) -> UIMenu {
        var menuActions: [UIAction] = []
        
        for (index, category) in viewModel.categories.enumerated() {
            menuActions.insert(UIAction(title: category.title, handler: { [weak self] _ in
                self?.viewModel.selectCategory(at: index)
                DispatchQueue.main.async {
                    self?.categoryButton.setTitle(category.title, for: .normal)
                    self?.categoryButton.sizeToFit()
                }
            }), at: 0)
        }
        
        menuActions.append(UIAction(title: "카테고리 설정", handler: { _ in
            let sheetViewController = CategorySettingsViewController(viewModel: self.viewModel)
            if let sheet = sheetViewController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
            self.present(sheetViewController, animated: true)
        }))
        
        return UIMenu(title: "카테고리 목록", children: menuActions)
    }
    
    private func updateCategoryMenu() {
        DispatchQueue.main.async {
            let menu = self.createCategoryMenu(categories: self.viewModel.categories)
            self.categoryButton.menu = menu
        }
        categoryButton.showsMenuAsPrimaryAction = true
    }
    
    private func loadCategories() {
        viewModel.handleCategoryId { [weak self] title in
            self?.categoryButton.setTitle(title, for: .normal)
            self?.categoryButton.sizeToFit()
            self?.updateCategoryMenu()
            self?.updateCategoryTitle()
        }
    }
    
    private func updateCategoryTitle() {
        guard let currentCategory = self.viewModel.currentCategory else { return }
        categoryButton.setTitle(currentCategory.title, for: .normal)
        categoryButton.sizeToFit()
    }
    
    // MARK: - Actions
    
    @objc private func bellButtonTapped() {
        pushViewController(NotificationViewController(), animated: true)
    }
    
    @objc private func gearButtonTapped() {
        pushViewController(SettingViewController(), animated: true)
    }
    
    @objc private func categoryButtonTapped() {
        DispatchQueue.main.async {
            self.updateCategoryMenu()
        }
    }
    
}
