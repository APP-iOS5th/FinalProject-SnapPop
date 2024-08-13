//
//  LocalAuthenticationViewModel.swift
//  SnapPop
//
//  Created by 이인호 on 8/12/24.
//

import Foundation
import LocalAuthentication

final class LocalAuthenticationViewModel {
    static func execute(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "인증이 필요합니다.") { (response, error) in
                if let error = error {
                    self.handleAuthenticationError(error: error as NSError)
                }
                completion(response, error)
            }
        } else {
            print("Local Authentication is not available")
        }
    }
    
    static func handleAuthenticationError(error: NSError) {
        switch error.code {
        case LAError.authenticationFailed.rawValue:
            print("authenticationFailed")
        case LAError.biometryNotEnrolled.rawValue:
            print("biometryNotEnrolled")
        case LAError.userFallback.rawValue:
            print("userFallback")
        default:
            return
        }
    }
}
