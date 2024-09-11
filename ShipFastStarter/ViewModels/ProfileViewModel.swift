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
    @Published var peopleList: [User] = [User.exUser, User.exUser]
    @Published var friends: [User] = []
    @Published var isVisitingProfile: Bool = false
    @Published var isCrush: Bool = false
    @Published var isFriend: Bool = false

    init() {
        
    }
    
    // MARK: - visiting profile functions
    func tappedAdd(currUser: User, friend: User, currentStatus: String) async {
        var newUser = currUser
        // fetch other user
        var selectedFriend = friend
        
        // determine status of friendship
        // check if it exists inside users friends dictionary
        if newUser.friends.contains(where: { k,v in
            k == friend.id
        }) {
            // update status, if friend is in dictionary means, they either sent friend request or are friends
            
            if let status = newUser.friends[friend.id] {
                if selectedFriend.friendRequests.contains(where: { k,v in
                    k == newUser.id //  "Sent 💌 status"
                }) { // needs to still be selectedFriend requests
                    // we need to remove request from friendRequests in
                    selectedFriend.friendRequests.removeValue(forKey: currUser.id)
                    newUser.friends.removeValue(forKey: friend.id)
                } else if selectedFriend.friends.contains(where: { k,v in
                    k == newUser.id // they are friends ✅, we need to unfriend
                }) {
                    selectedFriend.friends.removeValue(forKey: currUser.id)
                    // we need to remove friend from other friends object
                    newUser.friends.removeValue(forKey: friend.id)
                } else { // the friend declined the other users request so we need to show + Add status
                    newUser.friends[friend.id] = "Sent 💌"
                    // update other users friendRequests property with time stamp
                    selectedFriend.friendRequests[currUser.id] = "\(Date().toString(format: "yyyy-MM-dd HH:mm:ss"))"
                }
            }
        } else { // append friend to dictionary
            newUser.friends[friend.id] = "Sent 💌" 
            // update other users friendRequests property with time stamp
            selectedFriend.friendRequests[currUser.id] = "\(Date().toString(format: "yyyy-MM-dd HH:mm:ss"))"
        }
        
        do {
            try await FirebaseService.shared.updateDocument(collection: "users", object: newUser)
            try await FirebaseService.shared.updateDocument(collection: "users", object: selectedFriend)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadImages() async {
        // Fetch users from your data source
        
        // Preload profile images
        let imageUrls = peopleList.compactMap { URL(string: $0.proPic) }
        await ImageCache.shared.preloadImages(urls: imageUrls)
    }

    func fetchPeopleList(user: User) async {
        // fetch users from firebase with same highschool ID
        // TODO: lazy load users (when there's 60+ ? )
        do {
            peopleList = try await FirebaseService.shared.fetchDocuments(collection: "users", whereField: "schoolId", isEqualTo: user.schoolId)
        } catch {
            print(error.localizedDescription)
        }
        
        // fetch profile Images
        
        // need to determine if they are friends already, also need to determine if we sent friend request
        for person in peopleList {
            var newPerson = person
   
            if newPerson.friendRequests.keys.contains(user.id) {
                newPerson.friendsStatus =  "Sent 💌"
            } else if newPerson.friends.contains(where: { k,v in
                k == user.id // they are friends ✅, we need to unfriend
            }) {
                newPerson.friendsStatus =  "Friends ✅"
                friends.append(newPerson)
            } else { // the friend declined the other users request so we need to show + Add status
                newPerson.friendsStatus =  "Add +"
            }
            
            if let index = peopleList.firstIndex(where: { $0.id == newPerson.id }) {
                peopleList[index] = newPerson
            }
        }
        await loadImages()
        // Update the UI on the main thread
              DispatchQueue.main.async {
                  self.objectWillChange.send()
        }
    }
    
    func fetchUserProfile(id: String) {
        
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
                    newUser.proPic = url
                    do {
                      try await FirebaseService.shared.updateDocument(collection: "users", object: newUser)
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
