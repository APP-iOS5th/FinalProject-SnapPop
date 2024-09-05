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
    
    private var snapLabelTopConstraint: NSLayoutConstraint?
    private var popLabelTopConstraint: NSLayoutConstraint?
    
    private let snapLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center

        // 글자 간격 설정
        let kernValue: CGFloat = 8.0

        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.balooChettanExtraBold(size: 80),
            .foregroundColor: UIColor.white,
            .kern: kernValue
        ]

        let text = NSAttributedString(string: "Snap", attributes: textAttributes)
        label.attributedText = text

        // shadow 설정
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.shadowOpacity = 0.8
        label.layer.shadowRadius = 1

        return label
    }()

    private let popLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center

        // 글자 간격 설정
        let kernValue: CGFloat = 10.0

        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.balooChettanExtraBold(size: 80),
            .foregroundColor: UIColor.white,
            .kern: kernValue
        ]

        let text = NSAttributedString(string: "Pop", attributes: textAttributes)
        label.attributedText = text

        // shadow 설정
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.shadowOpacity = 0.8
        label.layer.shadowRadius = 1

        return label
    }()

    // google signing button custom
    private lazy var googleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Google로 로그인", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.tintColor = .none
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)

        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 2
        
        if let googleIcon = UIImage(named: "google_logo")?.withRenderingMode(.alwaysOriginal) {
            button.setImage(googleIcon, for: .normal)
        }
        button.imageView?.contentMode = .scaleAspectFit
        
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

        // Action for Google Sign-In
        button.addAction(UIAction { [weak self] _ in
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
        
        return button
    }()
    
    private lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
        let signInButton = ASAuthorizationAppleIDButton()
        // apple button shadow
        signInButton.layer.shadowColor = UIColor.gray.cgColor
        signInButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        signInButton.layer.shadowOpacity = 0.1
        signInButton.layer.shadowRadius = 2
        
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
        adjustLayoutForDeviceSize()
    }
    
    func configureUI() {
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "signin")
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)

        view.addSubview(snapLabel)
        view.addSubview(popLabel)
        view.addSubview(googleSignInButton)
        view.addSubview(appleSignInButton)

        snapLabel.translatesAutoresizingMaskIntoConstraints = false
        popLabel.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        snapLabelTopConstraint = snapLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 115)
        popLabelTopConstraint = popLabel.topAnchor.constraint(equalTo: snapLabel.bottomAnchor, constant: 105)
        
        NSLayoutConstraint.activate([
            snapLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            snapLabelTopConstraint!,
            popLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popLabelTopConstraint!,
            
            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInButton.bottomAnchor.constraint(equalTo: appleSignInButton.topAnchor, constant: -16),
            googleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            googleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            
            appleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleSignInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120),
            appleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            appleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // 화면 크기에 따른 레이아웃 조정 메서드
    private func adjustLayoutForDeviceSize() {
        let screenHeight = UIScreen.main.nativeBounds.height

        if screenHeight <= 1334 { // iPhone SE ,iPhone 8, 7, 6s, 6 (4.7인치 디스플레이)
            adjustForSmallScreen()
        } else if screenHeight <= 1792 { // iPhone 11, XR (6.1인치 디스플레이)
            // 기존 레이아웃 유지
        } else { // iPhone 15 Pro Max, iPhone 14 Pro Max, iPhone 13 Pro Max 등 (6.7인치 디스플레이)
            adjustForLargeScreen()
        }
    }
    
    // // iPhone SE ,iPhone 8 (4.7인치 디스플레이) 레이아웃 조정
    private func adjustForSmallScreen() {
        // 폰트 크기 조정
        let snapFont = UIFont.balooChettanExtraBold(size: 60)
        let popFont = UIFont.balooChettanExtraBold(size: 60)
        
        let snapTextAttributes: [NSAttributedString.Key: Any] = [
            .font: snapFont,
            .foregroundColor: UIColor.white,
            .kern: 6.0
        ]
        let popTextAttributes: [NSAttributedString.Key: Any] = [
            .font: popFont,
            .foregroundColor: UIColor.white,
            .kern: 8.0
        ]
        
        snapLabel.attributedText = NSAttributedString(string: "Snap", attributes: snapTextAttributes)
        popLabel.attributedText = NSAttributedString(string: "Pop", attributes: popTextAttributes)
        
        // 기존 제약 조건 해제
        if let snapTopConstraint = snapLabelTopConstraint, let popTopConstraint = popLabelTopConstraint {
            NSLayoutConstraint.deactivate([snapTopConstraint, popTopConstraint])
        }
        
        // small 제약 조건 설정 및 활성화
        snapLabelTopConstraint = snapLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120)
        popLabelTopConstraint = popLabel.topAnchor.constraint(equalTo: snapLabel.bottomAnchor, constant: 80)
        
        NSLayoutConstraint.activate([snapLabelTopConstraint!, popLabelTopConstraint!])
    }
    
    // // iPhone 15 Pro Max, iPhone 14 Pro Max (6.7인치 디스플레이) 레이아웃 조정
    private func adjustForLargeScreen() {
        // 폰트 크기 조정
        let snapFont = UIFont.balooChettanExtraBold(size: 90)
        let popFont = UIFont.balooChettanExtraBold(size: 90)
        
        let snapTextAttributes: [NSAttributedString.Key: Any] = [
            .font: snapFont,
            .foregroundColor: UIColor.white,
            .kern: 8.0
        ]
        let popTextAttributes: [NSAttributedString.Key: Any] = [
            .font: popFont,
            .foregroundColor: UIColor.white,
            .kern: 10.0
        ]
        
        snapLabel.attributedText = NSAttributedString(string: "Snap", attributes: snapTextAttributes)
        popLabel.attributedText = NSAttributedString(string: "Pop", attributes: popTextAttributes)
        
        // 기존 제약 조건 해제
        if let snapTopConstraint = snapLabelTopConstraint, let popTopConstraint = popLabelTopConstraint {
            NSLayoutConstraint.deactivate([snapTopConstraint, popTopConstraint])
        }
        
        // large 제약 조건 설정 및 활성화
        snapLabelTopConstraint = snapLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130)
        popLabelTopConstraint = popLabel.topAnchor.constraint(equalTo: snapLabel.bottomAnchor, constant: 100)
        
        NSLayoutConstraint.activate([snapLabelTopConstraint!, popLabelTopConstraint!])
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
