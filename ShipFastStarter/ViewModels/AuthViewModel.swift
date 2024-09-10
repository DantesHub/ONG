//
//  AuthViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/2/24.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var signInSuccessful = false
    @Published var signInError: Error?
    @Published var verificationID: String?
    @Published var isVerificationCodeSent = false
    @Published var isVerified = false
    @Published var errorString = ""
    func signInWithPhoneNumber(phoneNumber: String, completion: @escaping (Result<Void, Error>) -> Void) {
        FirebaseService.shared.signUpWithPhoneNumber(phoneNumber: phoneNumber) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let verificationID):
                    self.verificationID = verificationID
                    self.isVerificationCodeSent = true
                    print("Successfully sent verification code: \(verificationID)")
                    completion(.success(()))
                case .failure(let error):
                    self.signInError = error
                    print("Error signing in with phone number: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func isUserSignedIn() {
    if let user = Auth.auth().currentUser {
        // User is signed in
        self.signInSuccessful = true
        self.isVerified = true
        print("User is signed in with UID: \(user.uid)")
    } else {
        // No user is signed in
        self.signInSuccessful = false
        self.isVerified = false
        print("No user is currently signed in")
    }
    }
    
    @MainActor
    func verifyCode(verificationCode: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        if let verfId = verificationID {
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verfId,
                verificationCode: verificationCode
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Verification error: \(error.localizedDescription)")
                    if let authError = error as? AuthErrorCode {
                        print("Firebase Auth Error Code: \(authError.code.rawValue)")
                        print("Firebase Auth Error Message: \(authError.localizedDescription)")
                    }
                    completion(.failure(error))
                    return
                }
                
                guard let authResult = authResult else {
                    let error = NSError(domain: "FirebaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Auth result is nil"])
                    completion(.failure(error))
                    return
                }

                completion(.success(authResult))
            }
        }
       
        
       
    }
    
    func resendVerificationCode() {
        guard let phoneNumber = UserDefaults.standard.string(forKey: "userNumber") else {
               print("No phone number available to resend code")
               return
           }
           
           // Reset relevant states
           self.isVerificationCodeSent = false
           self.verificationID = nil
           self.signInError = nil
           
  
       }
}
