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
        
        setupTabbarLayout()
        setupTabbarItem()
    }
    
    private func setupTabbarLayout() {
        tabBar.tintColor = .customMain
        tabBar.barTintColor = .systemGray
        tabBar.backgroundColor = .customBackground
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
