//
//  AuthViewModel.swift
//  SnapPop
//
//  Created by 이인호 on 8/8/24.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FirebaseFirestore
import FirebaseStorage

final class AuthViewModel {
    static let shared = AuthViewModel()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    private let categoryService = CategoryService()
    
    var currentNonce: String?
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    func listenAuthState(_ listeningBlock: @escaping (Auth, User?) -> Void) {
        Auth.auth().addStateDidChangeListener(listeningBlock)
    }
    
    func signInWithGoogle(on viewController: UIViewController,
                          completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            guard error == nil else { return }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let user = authResult?.user {
                    self.saveUserToCollection(userId: user.uid)
                    completion(.success(user))
                }
            }
        }
    }
    
    func startSignInWithAppleFlow(on viewController: UIViewController,
                                  completion: @escaping (Result<User, Error>) -> Void) {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = viewController as? ASAuthorizationControllerDelegate
        authorizationController.presentationContextProvider = viewController as? ASAuthorizationControllerPresentationContextProviding
        authorizationController.performRequests()
    }
    
    func signInWithApple(idToken: String, rawNonce: String, fullName: PersonNameComponents?,
                         completion: @escaping (Result<User, Error>) -> Void) {
        guard currentNonce != nil else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."])))
            return
        }
        
        let credential = OAuthProvider.appleCredential(withIDToken: idToken, rawNonce: rawNonce, fullName: fullName)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                self.saveUserToCollection(userId: user.uid)
                completion(.success(user))
            }
        }
    }
    
    func saveUserToCollection(userId: String) {
        db.collection("Users")
            .document(userId)
            .setData([:])
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func deleteCurrentUser(on viewController: UIViewController) {
        guard let user = currentUser else {
            print("No current user found")
            return
        }
        
        guard let providerID = user.providerData.first?.providerID else {
            print("No provider ID found")
            return
        }
        
        if providerID == "google.com" {
            signInWithGoogle(on: viewController) { result in
                switch result {
                case .success:
                    user.delete { error in
                        if let error = error {
                            print("Error deleting user: \(error.localizedDescription)")
                        } else {
                            print("Successfully deleted user")
                            self.deleteUserFromCollection(userId: user.uid)
                        }
                    }
                case .failure(let error):
                    print("Error signing in: \(error.localizedDescription)")
                }
            }
        } else if providerID == "apple.com" {
            startSignInWithAppleFlow(on: viewController) { _ in
            }
        }
    }
    
    func deleteUserFromCollection(userId: String) {
        categoryService.deleteCategories(userId: userId) { result in
            switch result {
            case .success:
                self.db.collection("Users")
                    .document(userId)
                    .delete { error in
                        if let error = error {
                            print("Error deleting user data: \(error.localizedDescription)")
                        } else {
                            print("Successfully deleted user data")
                            NotificationManager.shared.removeAllNotifications()
                        }
                    }
            case .failure(let error):
                print("Error deleting user categories: \(error.localizedDescription)")
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
