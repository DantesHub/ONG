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
    @Published var verificationError: String?
    @Published var tappedLogin: Bool = false

    func signInWithPhoneNumber(phoneNumber: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let _ = Auth.auth().currentUser  {
            print("No authenticated user")
        }
        
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
                    print("Error signing in with phone number: \(error.localizedDescription) \(phoneNumber)")
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
        guard let verfId = verificationID else {
            self.verificationError = "Verification ID is missing. Please request a new code."
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Verification ID is missing"])))
            return
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verfId,
            verificationCode: verificationCode
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error as? AuthErrorCode {
                switch error.code {
                case .invalidVerificationCode, .invalidVerificationID:
                    self.verificationError = "Invalid verification code. Please try again."
                    self.resetVerificationProcess()
                case .sessionExpired:
                    self.verificationError = "Verification session has expired. Please request a new code."
                    self.resetVerificationProcess()
                default:
                    self.verificationError = "An error occurred: \(error.localizedDescription)"
                }
                completion(.failure(error))
                return
            }
            
            guard let authResult = authResult else {
                self.verificationError = "Authentication failed. Please try again."
                completion(.failure(NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Authentication result is nil"])))
                return
            }

            self.verificationError = nil
         
            completion(.success(authResult))
        }
    }

    private func resetVerificationProcess() {
        self.verificationID = nil
        self.isVerificationCodeSent = false
    }

    func resendVerificationCode() {
        guard let phoneNumber = UserDefaults.standard.string(forKey: "userNumber") else {
            print("No phone number available to resend code")
            return
        }
        
        // Reset relevant states
        self.resetVerificationProcess()
        
        // Resend the verification code
        self.signInWithPhoneNumber(phoneNumber: phoneNumber) { result in
            switch result {
            case .success:
                print("Verification code resent successfully")
            case .failure(let error):
                print("Error resending verification code: \(error.localizedDescription)")
                self.verificationError = "Failed to resend code. Please try again."
            }
        }
    }
}
