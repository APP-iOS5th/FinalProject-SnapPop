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
        tabBar.backgroundColor = .white
    }
    
    private func setupTabbarItem() {
        let firstViewController = TestCalendarViewController()
        firstViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.fill")
        )
        
        let secondViewController = HomeViewController()
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
        
        let firstNavController = CustomNavigationController(rootViewController: firstViewController)
        let secondNavController = CustomNavigationController(rootViewController: secondViewController)
        let thirdNavController = CustomNavigationController(rootViewController: thirdViewController)
        
        viewControllers = [
            firstNavController,
            secondNavController,
            thirdNavController
        ]
    }
}

