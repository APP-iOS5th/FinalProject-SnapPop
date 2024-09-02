//
//  TempViewController.swift
//  SnapPop
//
//  Created by 이인호 on 9/2/24.
//
// 카테고리 유무 조건에 따라 홈/카테고리 없음 스위칭해서 보여주는 뷰

import UIKit

class ConditionalViewController: UIViewController {
    var currentViewController: UIViewController?
    let viewModel: CustomNavigationBarViewModelProtocol
    
    private var currentCategoryId: String?
    
    init(viewModel: CustomNavigationBarViewModelProtocol) {
        self.viewModel = viewModel
        currentCategoryId = UserDefaults.standard.string(forKey: "currentCategoryId")
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .categoryDidChange, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(categoryDidChange(_:)), name: .categoryDidChange, object: nil)
        
        if currentCategoryId != nil {
            showHomeViewController()
        } else {
            showCategoryEmptyViewController()
        }
    }
    
    @objc private func categoryDidChange(_ notification: Notification) {
        let newCategoryId = UserDefaults.standard.string(forKey: "currentCategoryId")
        
        if newCategoryId != currentCategoryId {
            // 상태가 변경된 경우에만 업데이트
            if newCategoryId != nil {
                showHomeViewController()
            } else {
                showCategoryEmptyViewController()
            }
        }
        currentCategoryId = newCategoryId
    }
    

    func showHomeViewController() {
        let homeVC = HomeViewController(navigationBarViewModel: viewModel)
        switchViewController(homeVC)
    }
    
    func showCategoryEmptyViewController() {
        let categoryEmptyVC = CategoryEmptyViewController(viewModel: viewModel)
        switchViewController(categoryEmptyVC)
    }
    
    func switchViewController(_ newViewController: UIViewController) {
        // 기존 자식 뷰 컨트롤러를 제거
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        // 새로운 자식 뷰 컨트롤러를 추가
        addChild(newViewController)
        view.addSubview(newViewController.view)
        newViewController.view.frame = view.bounds
        newViewController.didMove(toParent: self)
        
        // 현재 자식 뷰 컨트롤러 업데이트
        currentViewController = newViewController
    }
}
