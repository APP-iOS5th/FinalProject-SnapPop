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
import AuthenticationServices

class SignInViewController: UIViewController {
    
    private let appName: UILabel = {
        let label = UILabel()
        label.text = "SNAP POP"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        return label
    }()
    
    private lazy var googleSignInButton: GIDSignInButton = {
        let signInButton = GIDSignInButton()
        
        signInButton.style = .wide
        
        signInButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            AuthViewModel.shared.signInWithGoogle(on: self) { result in
                switch result {
                case .success(let user):
                    print("Successfully signed in as user: \(user.uid)")
                    self.setupNotifications()
                case .failure(let error):
                    print("Error signing in: \(error.localizedDescription)")
                }
            }
        }, for: .touchUpInside)
        
        return signInButton
    }()
    
    private lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
        let signInButton = ASAuthorizationAppleIDButton()
        
        signInButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            AuthViewModel.shared.startSignInWithAppleFlow(on: self) { result in
                switch result {
                case .success(let user):
                    print("Successfully signed in as user: \(user.uid)")
                    self.setupNotifications()
                case .failure(let error):
                    print("Error signing in: \(error.localizedDescription)")
                }
            }
        }, for: .touchUpInside)
        
        return signInButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(appName)
        view.addSubview(googleSignInButton)
        view.addSubview(appleSignInButton)
        
        appName.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            appName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appName.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInButton.topAnchor.constraint(equalTo: appName.bottomAnchor, constant: 16),
            googleSignInButton.widthAnchor.constraint(equalToConstant: 200),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 40),
            
            appleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleSignInButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 8),
            appleSignInButton.widthAnchor.constraint(equalToConstant: 200),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupNotifications() {
        // 1. 이전에 있던 모든 알림 삭제
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // 2. 카테고리의 alertState가 true 일때 해당 Managements의 알림 추가
        NotificationSettingViewModel().loadCategories { [weak self] in
            guard let self = self else { return }
            let categories = NotificationSettingViewModel().categories
            categories.filter { $0.alertStatus }.forEach { category in
                NotificationSettingViewModel().registerAllNotifications(for: category.id ?? "")
            }
        }
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = AuthViewModel.shared.currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // 파이어베이스에 애플 인증 전달
            AuthViewModel.shared.signInWithApple(idToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName) { result in
                switch result {
                case .success(let user):
                    print("Successfully signed in as user: \(user.uid)")
                case .failure(let error):
                    print("Error signing in: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("Sign in with Apple errored: \(error.localizedDescription)")
    }
}
