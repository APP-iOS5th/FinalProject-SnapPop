//
//  SignInViewController.swift
//  SnapPop
//
//  Created by 이인호 on 8/8/24.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class SignInViewController: UIViewController {
    private let viewModel: AuthViewModel
    
    private lazy var googleSignInButton: GIDSignInButton = {
        let signInButton = GIDSignInButton()
        
        signInButton.style = .wide
        signInButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.googleSignIn(presentingViewController: self ?? UIViewController())
        }, for: .touchUpInside)
        
        return signInButton
    }()
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(googleSignInButton)
        
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

}
