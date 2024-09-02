//
//  CustomTabBarController.swift
//  SnapPop
//
//  Created by 정종원 on 8/19/24.
//

import UIKit

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        setupTabbarLayout()
        setupTabbarItem()
        selectedIndex = 1
    }

    override func loadView() {
        super.loadView()
        setValue(CustomTabBar(), forKey: "tabBar")
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
        let secondViewController = HomeViewController(navigationBarViewModel: customNavViewModel)
        secondViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
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

class CustomTabBar: UITabBar {
    var customHeight: CGFloat = 95 // 원하는 높이를 설정합니다.

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = customHeight
        return sizeThatFits
    }
}
