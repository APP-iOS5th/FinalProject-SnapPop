//
//  SnapComparisonSheetViewController.swift
//  SnapPop
//
//  Created by 정종원 on 8/9/24.
//

import UIKit

class SnapComparisonSheetViewController: UIViewController {
    // MARK: - Properties
    
    // MARK: - UIComponents
    
    private lazy var testLabel: UILabel = {
        let label = UILabel()
        label.text = "모다을 테스트"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubviews([
            testLabel
        ])
        
        NSLayoutConstraint.activate([
            testLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Methods
    
}
