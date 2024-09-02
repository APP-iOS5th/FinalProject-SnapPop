//
//  CustomTabBarController.swift
//  SnapPop
//
//  Created by 정종원 on 8/19/24.
//

import UIKit
import Combine

class CustomTabBarController: UITabBarController {
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        setupTabbarLayout()
        setupTabbarItem()
        selectedIndex = 1
        
        bind()
    }
    
    private func setupTabbarLayout() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .customBackground
        appearance.shadowColor = .black
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.customMain]
        appearance.stackedLayoutAppearance.selected.iconColor = .customMain
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupTabbarItem() {
        let firstViewController = CalendarViewController()
        firstViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.fill")
        )
        
        let customNavViewModel = CustomNavigationBarViewModel()
        var secondViewController: UIViewController
        
        if let currentCategoryId = UserDefaults.standard.string(forKey: "currentCategoryId") {
            secondViewController = HomeViewController(navigationBarViewModel: customNavViewModel)
            secondViewController.tabBarItem = UITabBarItem(
                title: "",
                image: UIImage(systemName: "house"),
                selectedImage: UIImage(systemName: "house.fill")
            )
        } else {
            secondViewController = CategoryEmptyViewController(viewModel: customNavViewModel)
            secondViewController.tabBarItem = UITabBarItem(
                title: "",
                image: UIImage(systemName: "house"),
                selectedImage: UIImage(systemName: "house.fill")
            )
        }
        
        let snapComparisonViewModel = SnapComparisonViewModel()
        let thirdViewController = SnapComparisonViewController(viewModel: snapComparisonViewModel)
        thirdViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "arrow.left.arrow.right.square"),
            selectedImage: UIImage(systemName: "arrow.left.arrow.right.square.fill")
        )
                
        let customNavigationBarViewModel = CustomNavigationBarViewModel()
        let firstNavController = CustomNavigationBarController(viewModel: customNavigationBarViewModel, rootViewController: firstViewController)
        let secondNavController = CustomNavigationBarController(viewModel: customNavigationBarViewModel, rootViewController: secondViewController)
        let thirdNavController = CustomNavigationBarController(viewModel: customNavigationBarViewModel, rootViewController: thirdViewController)
        
        viewControllers = [
            firstNavController,
            secondNavController,
            thirdNavController
        ]
    }
    
    private func setupSecondViewController() {
        let customNavViewModel = CustomNavigationBarViewModel()
        var secondViewController: UIViewController
        
        if let currentCategoryId = UserDefaults.standard.string(forKey: "currentCategoryId") {
            secondViewController = HomeViewController(navigationBarViewModel: customNavViewModel)
        } else {
            secondViewController = CategoryEmptyViewController(viewModel: customNavViewModel)
        }
        
        secondViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        let secondNavController = CustomNavigationBarController(viewModel: customNavViewModel, rootViewController: secondViewController)
        
        if var currentViewControllers = viewControllers {
            currentViewControllers[1] = secondNavController
            viewControllers = currentViewControllers
        } else {
            viewControllers = [secondNavController]
        }
    }
    
    private func bind() {
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification, object: nil)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.setupSecondViewController()
                self.selectedIndex = 1
            }
            .store(in: &cancellables)
    }
}

extension CustomTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let viewControllers = tabBarController.viewControllers {
            for controller in viewControllers {
                if let navigationController = controller as? CustomNavigationBarController {
                    navigationController.popToRootViewController(animated: false)
                }
            }
        }
        return true
    }
}
