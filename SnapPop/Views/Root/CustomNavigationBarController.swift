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
        config.baseForegroundColor = .dynamicTextColor
        
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
        loadCategories()
        updateCategoryMenu()
        
        // TODO: - categoryisUpdated를 왜 다시 정의해줘야 동작이 잘되는거지..?
        viewModel.categoryisUpdated = { [weak self] in
            print("CustomNavigationBarController에서 categoryisUpdated 클로저 호출됨")
            DispatchQueue.main.async {
                self?.updateCategoryMenu()
            }
        }
    }
    
    // MARK: - Methods
    private func setupCustomNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.customBackgroundColor
        
        appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20.0),
                                          .foregroundColor: UIColor.dynamicTextColor]
        
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .dynamicTextColor
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
    
    func updateCategoryMenu() {
        DispatchQueue.main.async { 
            let menu = self.createCategoryMenu(categories: self.viewModel.categories)
            print("새로운 메뉴가 설정되었습니다: \(menu)")
            self.categoryButton.menu = menu
            self.updateCategoryTitle()
            self.categoryButton.sizeToFit()
            self.categoryButton.layoutIfNeeded()
            print("Current category.id \(self.viewModel.currentCategory?.id)")
        }
        
    }
    
    func loadCategories() {
        viewModel.handleCategoryId { [weak self] title in
            self?.categoryButton.setTitle(title, for: .normal)
            self?.categoryButton.sizeToFit()
            self?.updateCategoryMenu()
        }
    }
    
    func updateCategoryTitle() {
        guard let currentCategory = self.viewModel.currentCategory else { 
            self.categoryButton.setTitle("카테고리 추가하기", for: .normal)
            return }
        self.categoryButton.setTitle(currentCategory.title, for: .normal)
        print("카테고리 타이틀 업데이트: \(currentCategory.title)")
        self.categoryButton.layoutIfNeeded()
    }
    
    // MARK: - Actions
    
    @objc private func bellButtonTapped() {
        let notificationVC = NotificationViewController()
        notificationVC.hidesBottomBarWhenPushed = true
        pushViewController(notificationVC, animated: true)
    }
    
    @objc private func gearButtonTapped() {
        let settingVC = SettingViewController()
        settingVC.hidesBottomBarWhenPushed = true
        pushViewController(settingVC, animated: true)
    }
    
    @objc private func categoryButtonTapped() {
        DispatchQueue.main.async {
            self.updateCategoryMenu()
        }
    }
    
}
