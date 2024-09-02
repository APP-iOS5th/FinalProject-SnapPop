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
    
    func setupRightBarButtonItemForNotification() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "알림 설정", style: .plain, target: self, action: #selector(moveToNotificationSettingView))
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func moveToNotificationSettingView() {
        let notiViewModel = NotificationSettingViewModel()
        let notificationSettingView = NotificationSettingViewController(viewModel: notiViewModel)
        navigationController?.pushViewController(notificationSettingView, animated: true)
    }
    
    func enableInteractivePopGesture() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
