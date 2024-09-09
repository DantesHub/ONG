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
    
    func signInWithPhoneNumber(phoneNumber: String) {
        FirebaseService.shared.signUpWithPhoneNumber(phoneNumber: phoneNumber) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let verificationID):
                    self.verificationID = verificationID
                    self.isVerificationCodeSent = true
                    print("Successfully sent verification code: \(verificationID)")
                case .failure(let error):
                    self.signInError = error
                    print("Error signing in with phone number: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor
    func verifyCode(code: String, user: User) {
        guard let verificationID = verificationID else { return }
        FirebaseService.shared.verifyCode(verificationID: verificationID, verificationCode: code) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let authResult):
                    FirebaseService.shared.addDocument(user, collection: "users") { str in
                        self.signInSuccessful = true
                        self.isVerified = true
                        print("Successfully verified and signed in: \(authResult.user.uid)")
                    }
                  
                case .failure(let error):
                    self.signInError = error
                    print("Error verifying code: \(error.localizedDescription)")
               
                }
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
           
           // Call signInWithPhoneNumber again
           signInWithPhoneNumber(phoneNumber: phoneNumber)
       }
}
