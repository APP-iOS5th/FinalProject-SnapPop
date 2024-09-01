//
//  UIViewController+Extensions.swift
//  SnapPop
//
//  Created by 이인호 on 9/1/24.
//

import UIKit

extension UIViewController {

    func setupLeftBarButtonItem() {
        let cancelButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = cancelButton
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
