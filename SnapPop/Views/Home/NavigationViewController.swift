//
//  NavigationViewController.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/8/24.
//

import UIKit

class NavigationViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(viewModel.categories.first?.name ?? "", for: .normal)

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let icon = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig)
        button.setImage(icon, for: .normal)
        
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        
        return button
    }()
    
    private var isMenuOpen = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: 네비게이션 바 요소 설정
        setupNavigationBar()
    }
    
    // MARK: 네비게이션 바 요소 설정
    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.prefersLargeTitles = false
            navigationBar.tintColor = .black
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        }
        
        let categoryButtonItem = UIBarButtonItem(customView: categoryButton)
        let alarmButton = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(alarmButtonTapped))
        let settingsButton = UIBarButtonItem(image: UIImage(named: "SettingsIcon"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        
        navigationItem.leftBarButtonItem = categoryButtonItem
        navigationItem.rightBarButtonItems = [settingsButton, alarmButton]
    }
    
    // MARK: 카테고리 버튼 클릭 시 메뉴 항목이 호출되는 메서드입니다.
    @objc private func menuButtonTapped(_ sender: UIButton) {
        // 애니메이션 추가
        toggleMenuState()
        
        let actions: [UIAction] = viewModel.categories.map { category in
            UIAction(title: category.name) { _ in
                self.handleMenuSelection(item: category)
            }
        }
        let addCategoryAction = UIAction(title: "카테고리 추가 설정") { _ in
            self.handleAddCategory()
        }
        
        let menu = UIMenu(children: actions + [addCategoryAction])
        
        categoryButton.menu = menu
        categoryButton.showsMenuAsPrimaryAction = true
    }
    
    // MARK: Toggle menu state
    private func toggleMenuState() {
        isMenuOpen.toggle()
        animateChevron()
    }
    
    // MARK: Chevron rotation animation
    private func animateChevron() {
        let rotationAngle: CGFloat = isMenuOpen ? .pi : 0 // 180도 회전
        UIView.animate(withDuration: 0.3) {
            self.categoryButton.imageView?.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
    
    // MARK: 선택된 카테고리를 처리하는 메서드
    private func handleMenuSelection(item: Category) {
        // 카테고리 버튼의 제목을 선택된 카테고리로 업데이트
        categoryButton.setTitle(item.name, for: .normal)
        
        toggleMenuState() // 메뉴 상태 토글 및 애니메이션
    }
    
    // MARK: "카테고리 추가 설정" 버튼 클릭 시 카테고리 설정 시트뷰 호출되는 메서드
    private func handleAddCategory() {
        print("Add Category button tapped")
        toggleMenuState() // 메뉴 상태 토글 및 애니메이션
    }
    
    // MARK: 네비게이션에 위치한 알림뷰로 이동합니다.
    @objc private func alarmButtonTapped() {
        closeMenuIfOpen() // 메뉴가 열려있으면 닫기
        let secondVC = EmptyViewController()
        navigationController?.pushViewController(secondVC, animated: true)
        print("Bell button tapped")
    }
    
    // MARK: 네비게이션에 위치한 설정뷰로 이동합니다.
    @objc private func settingsButtonTapped() {
        closeMenuIfOpen() // 메뉴가 열려있으면 닫기
        let secondVC = EmptyViewController()
        navigationController?.pushViewController(secondVC, animated: true)
        print("Setting button tapped")
    }
    
    // MARK: 메뉴가 열려있으면 닫는 메서드
    private func closeMenuIfOpen() {
        if isMenuOpen {
            isMenuOpen = false
            animateChevron() // 아이콘 회전 애니메이션
        }
    }
}
