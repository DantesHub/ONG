//
//  ProfileViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/9/24.
//

import Foundation
import UIKit
import FirebaseAuth
class ProfileViewModel: ObservableObject {
    @Published var profileImage: UIImage?

    init() {
    }

    func fetchUserProfilePicture(user: User) {
        guard let _ = Auth.auth().currentUser else {
            print("No authenticated user")
            return
        }
        
        FirebaseService.shared.fetchImage(path: "profileImages/\(user.username)") { result in
            switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.profileImage = image
                    }
                case .failure(let error):
                    print("Error fetching profile image: \(error.localizedDescription)")
            }
        }
    }
    

    func uploadUserProfilePicture(image: UIImage, user: User) -> User {
  
        let path = "profileImages/\(user.username)"
        FirebaseService.shared.uploadImage(image, path: path) { result in
            // Handle the result of the upload
            // If successful, update the profileImage
            switch result {
            case .success(let url):
                Task {
                    var newUser = user
                    newUser.proPic = true
                    do {
                      try await FirebaseService.shared.updateDocument(collection: "users", object: user)
                    } catch {
                        print(error.localizedDescription)
                    }
                    return newUser
                }
            case .failure(let error):
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
        return user
    }
}
