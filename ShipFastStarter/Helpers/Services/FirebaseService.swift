import Firebase
import FirebaseAuth
import FirebaseFirestore
import UIKit
import FirebaseMessaging
import FirebaseStorage

class FirebaseService {
    static let shared = FirebaseService()
    static let db = Firestore.firestore()
    private let storage = Storage.storage().reference()

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
    
    //MARK: - Firestore database
     func batchSave(documents: [(collection: String, data: [String: Any])]) async throws {
        let batch = Firestore.firestore().batch()
        
        for doc in documents {
            let ref = Firestore.firestore().collection(doc.collection).document()
            batch.setData(doc.data, forDocument: ref)
        }
        
        try await batch.commit()
    }
    
    
    
    func addDocument(_ object: FBObject, collection: String, completion: @escaping (String?) -> Void) {
        if let dict = object.encodeToDictionary() {
            let id = dict["id"] as! String
            let ref = FirebaseService.db.collection(collection).document(id)
            ref.setData(dict) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    completion(nil)
                } else {
                    print("Document added with ID: \(ref.documentID)")
                    completion(ref.documentID)
                }
            }
            
        } else {
            print("error here")
            completion(nil)
        }
    }
    
    func updateDocument(collection: String, field: String, isEqualTo: String, object: FBObject) async throws  {
        let query = FirebaseService.db.collection(collection).whereField(field, isEqualTo: isEqualTo)
        let querySnapshot = try await query.getDocuments()
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let data = object.encodeToDictionary(), let id = data["id"] as? String else {
                continuation.resume(throwing: NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to encode object to dictionary or missing id"]))
                return
            }
          
                
                guard let document = querySnapshot.documents.first else {
                    continuation.resume(throwing: NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No matching document found"]))
                    return
                }
                
                document.reference.setData(data, merge: true) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        print("Document successfully updated")
                        continuation.resume(returning: ())
                    }
                }            
        }
        
    }
    
     func updateDocument(collection: String, object: FBObject) async throws {
        let documentCollection = FirebaseService.db.collection(collection)
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let data = object.encodeToDictionary(), let id = data["id"] as? String else {
                continuation.resume(throwing: NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to encode object to dictionary or missing id"]))
                return
            }
            
            documentCollection.whereField("id", isEqualTo: id).getDocuments { (querySnapshot, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let document = querySnapshot?.documents.first else {
                    continuation.resume(throwing: NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No matching document found"]))
                    return
                }
                
                document.reference.setData(data, merge: true) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        print("Document successfully updated")
                        continuation.resume(returning: ())
                    }
                }
            }
        }
    }
    
    //MARK: - get methods
    static func getUser(completion: @escaping (Result<User, Error>) -> Void) {
        if let number = UserDefaults.standard.string(forKey: "userNumber") {
            print(number, "shibal")
            let userCollection = FirebaseService.db.collection("users")
            userCollection.whereField("number", isEqualTo: number).getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                // Assuming there's only one user with this phone number
                if let document = querySnapshot?.documents.first {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        var retUser = try JSONDecoder().decode(User.self, from: jsonData)
//                        FirebaseService.getImage(path: retUser.proPic) { result in
//                            switch result {
//                            case .success(let data):
//                                retUser.proPicData = data
//                            case .failure(let error):
//                                print(error.localizedDescription)
//                            }
//                        }
                            completion(.success(retUser))
                    } catch let decodeError {
                        completion(.failure(decodeError))
                    }
                } else {
                    // Handle the case where no documents are found
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found with that phone number"])))
                }
            }
        }
    }
    
    //MARK: - Getter Methods
    func getDocument<T: Codable>(collection: String, documentId: String) async throws -> T {
        let docRef = FirebaseService.db.collection(collection).document(documentId)
        let snapshot = try await docRef.getDocument()
        
        guard let data = snapshot.data() else {
            throw NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found"])
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }

    static func getDocuments<T: Codable>(collection: String, limit: Int? = nil) async throws -> [T] {
        var query: Query = db.collection(collection)
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let querySnapshot = try await query.getDocuments()
        return try querySnapshot.documents.compactMap { document in
            let jsonData = try JSONSerialization.data(withJSONObject: document.data())
            return try JSONDecoder().decode(T.self, from: jsonData)
        }
    }

    static func getDocumentsWhere<T: Codable>(collection: String, field: String, isEqualTo: Any) async throws -> [T] {
        let query = db.collection(collection).whereField(field, isEqualTo: isEqualTo)
        let querySnapshot = try await query.getDocuments()
        
        return try querySnapshot.documents.compactMap { document in
            let jsonData = try JSONSerialization.data(withJSONObject: document.data())
            return try JSONDecoder().decode(T.self, from: jsonData)
        }
    }

    static func getFilteredDocuments<T: Codable>(collection: String, filterField: String, filterValue: Any) async throws -> [T] {
        let query = db.collection(collection).whereField(filterField, isEqualTo: filterValue)
        let querySnapshot = try await query.getDocuments()
        
        return try querySnapshot.documents.compactMap { document in
            let jsonData = try JSONSerialization.data(withJSONObject: document.data())
            return try JSONDecoder().decode(T.self, from: jsonData)
        }
    }


    func fetchDocuments<T: Codable>(
        collection: String,
        whereField: String? = nil,
        isEqualTo: Any? = nil,
        limit: Int? = nil
    ) async throws -> [T] {
        var query: Query = FirebaseService.db.collection(collection)
        
        if let whereField = whereField, let isEqualTo = isEqualTo {
            query = query.whereField(whereField, isEqualTo: isEqualTo)
        }
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let querySnapshot = try await query.getDocuments()
        
        return try querySnapshot.documents.compactMap { document in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                return try JSONDecoder().decode(T.self, from: jsonData)
            } catch {
                print("Error decoding document \(collection) \(document.documentID): \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value of type '\(type)' not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch for type '\(type)': \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                return nil
            }
        }
    }
    
    //MARK: - revert
     func updateAllObjects(collection: String) async throws {
        let db = Firestore.firestore()
        let documentCollection = db.collection(collection)

        // Start a new write batch
        let batch = db.batch()
        
        do {
            let querySnapshot = try await documentCollection.getDocuments()
             let documents = querySnapshot.documents

            for doc in documents {
                if var user = try? doc.data() {
                    let documentRef = documentCollection.document(doc.documentID)
                    user["friendRequests"] = [:]
                    user["friends"] = [:]
                    print(doc.documentID, "documentID")
                    try await documentRef.updateData(user)
                  }
              }
                
                

            try await batch.commit()
            print("Batch write succeeded.")
        } catch {
            print("Error: \(error)")
        }
    }

    func isUsernameTaken(_ username: String) async throws -> Bool {
        let usersRef = FirebaseService.db.collection("users")
        let query = usersRef.whereField("username", isEqualTo: username)
        
        do {
            let snapshot = try await query.getDocuments()
            return !snapshot.isEmpty
        } catch {
            print("Error checking username: \(error.localizedDescription)")
            throw error
        }
    }

  func uploadImage(_ image: UIImage, path: String, completion: @escaping (Result<String, Error>) -> Void) {
    print("Starting image upload process for path: \(path)")
    
    guard let imageData = image.jpegData(compressionQuality: 0.5) else {
        print("Failed to convert image to JPEG data")
        completion(.failure(NSError(domain: "FirebaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
        return
    }
    
    print("Image converted to JPEG data. Size: \(imageData.count) bytes")

    let imageRef = storage.child(path)
    print("Uploading image to Firebase Storage at path: \(path)")
    
    imageRef.putData(imageData, metadata: nil) { metadata, error in
        if let error = error {
            print("Error uploading image: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        print("Image uploaded successfully. Metadata: \(String(describing: metadata))")
        
        // Fetch the download URL
        imageRef.downloadURL { url, error in
            if let error = error {
                print("Error getting download URL: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let downloadURL = url else {
                print("Download URL is nil")
                completion(.failure(NSError(domain: "FirebaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                return
            }
            
            print("Download URL obtained successfully: \(downloadURL.absoluteString)")
            completion(.success(downloadURL.absoluteString))
        }
    }
}

    func fetchImage(path: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let imageRef = storage.child(path)
        
        imageRef.getData(maxSize: 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let imageData = data, let image = UIImage(data: imageData) else {
                completion(.failure(NSError(domain: "FirebaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to image"])))
                return
            }
            
            completion(.success(image))
        }
    }


}
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
