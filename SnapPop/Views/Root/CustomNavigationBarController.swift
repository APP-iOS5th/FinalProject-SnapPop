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
    private lazy var categoryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "카테고리"
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 10
        config.baseForegroundColor = .black
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.menu = self.createCategoryMenu(categories: viewModel.categories)
        button.showsMenuAsPrimaryAction = true
        button.sizeToFit()
        
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
        setupCustomNavigationBar()
        loadCategories()
        updateCategoryTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarItems()
        updateCategoryTitle()
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
    }
    
    private func createCategoryMenu(categories: [Category]) -> UIMenu {
        var categories = categories
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
            // TODO: - 카테고리 설정 구현
            let sheetViewController = CategorySettingsViewController()
            if let sheet = sheetViewController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
            self.present(sheetViewController, animated: true)
        }))
        
        return UIMenu(title: "카테고리 목록", children: menuActions)
    }
    
    private func updateCategoryMenu() {
        let menu = createCategoryMenu(categories: viewModel.categories)
        categoryButton.menu = menu
        categoryButton.showsMenuAsPrimaryAction = true
    }
    
    private func loadCategories() {
        viewModel.loadCategories { [weak self] in
            DispatchQueue.main.async {
                self?.updateCategoryMenu()
            }
        }
    }
    
    private func updateCategoryTitle() {
        guard let currentCategory = viewModel.currentCategory else { return }
        self.categoryButton.setTitle(currentCategory.title, for: .normal)
    }
    
    // MARK: - Actions
    
    @objc private func bellButtonTapped() {
        print("Bell button tapped")
        pushViewController(NotificationViewController(), animated: true)
    }
    
    @objc private func gearButtonTapped() {
        print("Gear button tapped")
        pushViewController(SettingViewController(), animated: true)
    }
    
}
