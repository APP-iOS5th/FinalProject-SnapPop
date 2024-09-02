//
//  LegalViewController.swift
//  SnapPop
//
//  Created by 이인호 on 8/20/24.
//

import UIKit

class LegalViewController: UIViewController {
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        return textView
    }()
    
    let legalType: LegalType
    
    init(legalType: LegalType) {
        self.legalType = legalType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupTextView()
        
        title = legalType.rawValue
        setupLeftBarButtonItem()
        enableInteractivePopGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        enableInteractivePopGesture()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTextView() {
        switch legalType {
        case .privacyPolicy:
            textView.text = LegalType.privacyPolicy.content
        case .dataUsagePolicy:
            textView.text = LegalType.dataUsagePolicy.content
        case .termsOfService:
            textView.text = LegalType.termsOfService.content
        }
    }
}
