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
            if let id = doc.data["id"] as? String {
                let docRef = Firestore.firestore().collection(doc.collection).document(id)
                batch.setData(doc.data, forDocument: docRef)
            } else {
                print("Error: 'id' not found or not a string in document data")
                throw NSError(domain: "FirebaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid 'id' in document data"])
            }
        }
        
        try await batch.commit()
    }

    
    // Batch update function
    func batchUpdate<T: FBObject>(collection: String, objects: [T]) async throws {
        let batch = Firestore.firestore().batch()
        
        for object in objects {
            guard let data = object.encodeToDictionary() else {
                throw NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to encode object to dictionary"])
            }
            let ref = Firestore.firestore().collection(collection).document(object.id)
            batch.setData(data, forDocument: ref, merge: true)
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
                        print(document["friends"], "Document successfully updated")
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
            let userCollection = FirebaseService.db.collection(FirestoreCollections.users)
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

    func fetchDocumentsWithFilters<T: Codable>(
        collection: String,
        whereField: String,
        isEqualTo: Any,
        additionalFilters: [(String, String, Any)] = [],
        orderBy: (String, Bool)? = nil,
        limit: Int? = nil
    ) async throws -> [T] {
        let db = Firestore.firestore()
        var query: Query = db.collection(collection).whereField(whereField, isEqualTo: isEqualTo)
        
        for filter in additionalFilters {
            switch filter.1 {
            case "isEqualTo":
                query = query.whereField(filter.0, isEqualTo: filter.2)
            case "notIn":
                if let array = filter.2 as? [Any], !array.isEmpty {
                    query = query.whereField(filter.0, notIn: array)
                }
            case "in":
                if let array = filter.2 as? [Any], !array.isEmpty {
                    query = query.whereField(filter.0, in: array)
                }
            default:
                break
            }
        }
        
        if let (field, descending) = orderBy {
            query = query.order(by: field, descending: descending)
        }
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let snapshot = try await query.getDocuments()
        return try snapshot.documents.compactMap { document in
            let jsonData = try JSONSerialization.data(withJSONObject: document.data())
            return try JSONDecoder().decode(T.self, from: jsonData)
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
        let usersRef = FirebaseService.db.collection(FirestoreCollections.users)
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
      if  let newImage = image.resized(to: CGSize(width: 1024, height: 256)) {
          guard let imageData = newImage.jpegData(compressionQuality: 0.5) else {
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

    func updateField(collection: String, documentId: String, field: String, value: Any) async throws {
        let docRef = FirebaseService.db.collection(collection).document(documentId)
        
        do {
            try await docRef.updateData([field: value])
            print("Document successfully updated")
        } catch {
            print("Error updating document: \(error)")
            throw error
        }
    }

    func updateFields(collection: String, documentId: String, fields: [String: Any]) async throws {
        let docRef = FirebaseService.db.collection(collection).document(documentId)
        
        do {
            try await docRef.updateData(fields)
            print("Document successfully updated with multiple fields")
        } catch {
            print("Error updating document with multiple fields: \(error)")
            throw error
        }
    }

    func deleteDocument(collection: String, documentId: String) async throws {
        let documentRef = FirebaseService.db.collection(collection).document(documentId)
        try await documentRef.delete()
        print("Document successfully deleted")
    }
    
    func incrementReferralCount(forUsername username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        UserDefaults.standard.set("", forKey: "referrerUsername")

        let db = Firestore.firestore()
        
        // Query to find the user document based on the username
        let userDoc = db.collection(FirestoreCollections.users).whereField("username", isEqualTo: username)
        
        userDoc.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                print("No user found with username: \(username)")
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            
            // Increment the 'referral' key in the user document
            document.reference.updateData(["referral": FieldValue.increment(Int64(1))]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func removeUserFromPollOptions(user: User) async throws {
        let db = Firestore.firestore()
        let pollsRef = db.collection(FirestoreCollections.polls)
        let userId = user.id
        // Get all polls
        let querySnapshot = try await pollsRef.getDocuments()
        
        for document in querySnapshot.documents {
            let pollRef = pollsRef.document(document.documentID)
            
            // Get the current poll data
            let pollData = document.data()
            guard var pollOptions = pollData["pollOptions"] as? [[String: Any]] else {
                continue
            }
            
            var userWasRemoved = false
            
            // Remove the user from usersWhoVoted array
            if var usersWhoVoted = pollData["usersWhoVoted"] as? [String], usersWhoVoted.contains(userId) {
                usersWhoVoted.removeAll { $0 == userId }
                userWasRemoved = true
                try await pollRef.updateData([
                    "usersWhoVoted": usersWhoVoted
                ])
            }
            
            // Remove the user from poll options
            pollOptions.removeAll { option in
                guard let optionUserId = option["userId"] as? String else { return false }
                return optionUserId == userId
            }
            
            if pollOptions.count != (pollData["pollOptions"] as? [[String: Any]])?.count {
                userWasRemoved = true
            }
            
            // Update the poll with the modified poll options only if the user was removed
            if userWasRemoved && pollData["schoolId"] as? String == user.schoolId {
                do {
                    try await pollRef.updateData([
                        "pollOptions": pollOptions
                    ])
                    print("Updated poll: \(document.documentID)")
                } catch {
                    print("Unable to update poll option for poll: \(document.documentID)")
                }
            }
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

import UIKit
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
      let aspectWidth = size.width / self.size.width
      let aspectHeight = size.height / self.size.height
      let aspectRatio = min(aspectWidth, aspectHeight)
      
      let newSize = CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio)
      
      UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
      let context = UIGraphicsGetCurrentContext()
      context?.interpolationQuality = .high
      self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
      let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return resizedImage
    }
    
}
