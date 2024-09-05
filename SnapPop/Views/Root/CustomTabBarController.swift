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
    }

    override func loadView() {
        super.loadView()
        setValue(CustomTabBar(), forKey: "tabBar")
    }

    private func setupTabbarLayout() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.customBackgroundColor
        appearance.shadowColor = .dynamicTextColor
        let thinLineImage = createThinLineImage(color: UIColor.dynamicTextColor, height: 0.1)
            appearance.shadowImage = thinLineImage
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.customMainColor]
        appearance.stackedLayoutAppearance.selected.iconColor = .customMainColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupTabbarItem() {
        let firstViewController = CalendarViewController()
        firstViewController.tabBarItem = UITabBarItem(
            title: "달력",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.fill")
        )
        
        let customNavigationBarViewModel = CustomNavigationBarViewModel()
        let secondViewController = ConditionalViewController(viewModel: customNavigationBarViewModel)
        secondViewController.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        let snapComparisonViewModel = SnapComparisonViewModel()
        let thirdViewController = SnapComparisonViewController(viewModel: snapComparisonViewModel)
        thirdViewController.tabBarItem = UITabBarItem(
            title: "비교",
            image: UIImage(systemName: "arrow.left.arrow.right.square"),
            selectedImage: UIImage(systemName: "arrow.left.arrow.right.square.fill")
        )
        let firstNavController = CustomNavigationBarController(viewModel: customNavigationBarViewModel, rootViewController: firstViewController)
        let secondNavController = CustomNavigationBarController(viewModel: customNavigationBarViewModel, rootViewController: secondViewController)
        let thirdNavController = CustomNavigationBarController(viewModel: customNavigationBarViewModel, rootViewController: thirdViewController)
        
        viewControllers = [
            firstNavController,
            secondNavController,
            thirdNavController
        ]
    }
    
    private func createThinLineImage(color: UIColor, height: CGFloat) -> UIImage {
        let size = CGSize(width: 1, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
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
    override func sizeThatFits(_ size: CGSize) -> CGSize {
           var sizeThatFits = super.sizeThatFits(size)
           
           // 디바이스 크기에 따라 탭바 높이 조절
           let screenHeight = UIScreen.main.bounds.height
           if screenHeight <= 667 { // iPhone SE, 8, 7, 6s, 6 (4.7" 디스플레이)
               sizeThatFits.height = 60
           } else {
               sizeThatFits.height = 95 // 큰 화면에 대해서는 기존 높이 유지
           }
           
           return sizeThatFits
       }
}
