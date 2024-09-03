import Firebase
import FirebaseAuth
import FirebaseFirestore
import UIKit

class FirebaseService {
    static let shared = FirebaseService()
    
    private init() {}
    
    // MARK: - Authentication

    func signUpWithPhoneNumber(phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        let authUI = PhoneAuthUIDelegate()
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: authUI) { verificationID, error in
            if let error = error {
                print("Detailed error: \(error.localizedDescription)")
                if let authError = error as? AuthErrorCode {
                    print("Firebase Auth Error Code: \(authError.code.rawValue)")
                    print("Firebase Auth Error Message: \(authError.localizedDescription)")
                }
                completion(.failure(error))
                return
            }

            guard let verificationID = verificationID else {
                let error = NSError(domain: "FirebaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Verification ID is nil"])
                completion(.failure(error))
                return
            }

            completion(.success(verificationID))
        }
    }

    func verifyCode(verificationID: String, verificationCode: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
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

    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - Database Operations
    
    func fetchData(collection: String, document: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Implement Firestore data fetching
    }
    
    func saveData(collection: String, document: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        // Implement Firestore data saving
    }
    
    // Add more methods as needed for your specific Firebase interactions
}

// MARK: - PhoneAuthUIDelegate

class PhoneAuthUIDelegate: NSObject, AuthUIDelegate {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if let topController = UIApplication.shared.windows.first?.rootViewController?.presentedViewController {
            topController.dismiss(animated: flag, completion: completion)
        }
    }
}
