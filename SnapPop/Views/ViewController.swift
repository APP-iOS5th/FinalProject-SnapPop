//
//  ViewController.swift
//  SnapPop
//
//  Created by 김형준 on 8/7/24.
//

import UIKit

class ViewController: UIViewController {

    private let addManagementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("새로운 관리 추가하기", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(addManagementButton)
        
        NSLayoutConstraint.activate([
            addManagementButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addManagementButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addManagementButton.widthAnchor.constraint(equalToConstant: 200),
            addManagementButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        addManagementButton.addTarget(self, action: #selector(addManagementButtonTapped), for: .touchUpInside)
    }

    @objc private func addManagementButtonTapped() {
        let viewModel = AddManagementViewModel()
        let addManagementViewController = AddManagementViewController(viewModel: viewModel)
        navigationController?.pushViewController(addManagementViewController, animated: true)
    }
}
