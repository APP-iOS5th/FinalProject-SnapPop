//
//  UIViewController+Extensions.swift
//  SnapPop
//
//  Created by 이인호 on 9/1/24.
//

import UIKit

extension UIViewController: UIGestureRecognizerDelegate {
    
    func setupLeftBarButtonItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func enableInteractivePopGesture() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
