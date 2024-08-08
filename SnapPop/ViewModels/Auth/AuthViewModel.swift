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

final class AuthViewModel {
    func googleSignIn(presentingViewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            guard error == nil else { return }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { _, _ in
                
            }
        }
    }

    func googleSignOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("SignOut Failed: \(signOutError.localizedDescription)")
        }
    }
}
