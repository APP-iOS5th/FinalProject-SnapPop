//
//  CustomNavigationBarController.swift
//  SnapPop
//
//  Created by 정종원 on 8/19/24.
//

import UIKit

class CustomNavigationBarController: UINavigationController {
    
    //MARK: - Properties
    var categories: [Category] = [Category(userId: "123123", title: "관리 1", alertStatus: false),
                                  Category(userId: "1212", title: "관리 2", alertStatus: false),
                                  Category(userId: "1111", title: "관리 3", alertStatus: false),
                                  Category(userId: "1111", title: "카테고리 설정", alertStatus: false)
    ]
    //    var categories: [Category] = []
    //    private let categoryService = CategoryService()
    
    //MARK: - UI Components
    private lazy var categoryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "카테고리"
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 10
        config.baseForegroundColor = .black
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.menu = self.createCategoryMenu(categories: categories)
        button.showsMenuAsPrimaryAction = true
        button.sizeToFit()
        
        return button
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavigationBar()
//        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarItems()
    }
    
    //MARK: - Methods
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
        //        categories.append("카테고리 설정") // load카테고리 이후 마지막에 카테고리 설정을 넣어줌
        
        for category in categories {
            menuActions.append(UIAction(title: category.title, handler: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.categoryButton.setTitle(category.title, for: .normal)
                }
                print("\(category) selected")
            }))
        }
        return UIMenu(title: "카테고리 목록", children: menuActions)
    }
    
    private func updateCategoryMenu() {
        let menu = createCategoryMenu(categories: categories)
        categoryButton.menu = menu
        categoryButton.showsMenuAsPrimaryAction = true
    }
    
    //    private func loadCategories() {
    //        categoryService.loadCategories { result in
    //            switch result {
    //            case .success(let categories):
    //                if categories.isEmpty {
    //                    // TODO: - 파이어베이스에 카테고리가 없을 경우 생각
    //                } else {
    //                    self.categories = categories
    //                    DispatchQueue.main.async {
    //                        self.updateCategoryMenu()
    //                    }
    //                }
    //            case .failure(let error):
    //                print("Failed to load categories: \(error.localizedDescription)")
    //            }
    //        }
    //    }
    
    //MARK: - Actions
    
    @objc private func bellButtonTapped() {
        print("Bell button tapped")
        pushViewController(NotificationViewController(), animated: true)
    }
    
    @objc private func gearButtonTapped() {
        print("Gear button tapped")
        pushViewController(SettingViewController(), animated: true)
    }
    
}
