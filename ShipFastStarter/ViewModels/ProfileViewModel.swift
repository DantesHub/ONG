//
//  ProfileViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/9/24.
//

import Foundation
import UIKit
import FirebaseAuth

class ProfileViewModel: ObservableObject, ImageUploadable {
    @Published var profileImage: UIImage?
    @Published var peopleList: [User] = []
    @Published var friends: [User] = []
    @Published var isVisitingProfile: Bool = false
    @Published var isCrush: Bool = false
    @Published var isFriend: Bool = false
    @Published var showFriendsScreen: Bool = false
    @Published var showingImagePicker = false
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var editProfile: Bool = false
    @Published var topEight: [User] = []

    init() {
        
    }
    
    func fetchTop8() {
        topEight = peopleList.sorted(by: { user1, user2 in
            user1.aura > user2.aura
        })
    }

    func addFriends(currUser: User, users: [User]) async  -> User{
        // we have to update each document sepeartely
        var newUser = currUser
        var newFriends: [User] = []
        for friend in users {
            var newFriend = friend
            newUser.friends[friend.id] = Date().toString(format: "yyyy-MM-dd HH:mm:ss")
            newFriend.friendRequests[newUser.id] = Date().toString(format: "yyyy-MM-dd HH:mm:ss")
            
            do {
                try await FirebaseService.shared.updateField(collection: "users", documentId: newFriend.id, field: "friendRequests", value: newFriend.friendRequests)
            } catch {
                print(error.localizedDescription)
            }
            
            newFriends.append(newFriend)
        }
        newFriends.append(newUser)
        
        do {
            try await FirebaseService.shared.updateField(collection: "users", documentId: currUser.id, field: "friends", value: newUser.friends)
        } catch {
            print(error.localizedDescription)
        }
        return newUser
    }
    
    // MARK: - visiting profile functions
    func tappedAdd(currUser: User, friend: User, currentStatus: String) async -> User {
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
        
        if let index = peopleList.firstIndex(where: { $0.id == selectedFriend.id }) {
            peopleList[index] = selectedFriend
        }
        return newUser
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
            }) && !newPerson.friendRequests.contains(where: { k,v in
                k == user.id
            }) {
                newPerson.friendsStatus =  "Friends ✅"
                if !friends.contains(where: { usr in
                    usr.id == newPerson.id
                }) {
                    friends.append(newPerson)
                }
            } else { // the friend declined the other users request so we need to show + Add status
                newPerson.friendsStatus =  "Add +"
            }
            
       
            if let index = peopleList.firstIndex(where: { $0.id == newPerson.id }) {
                peopleList[index] = newPerson
            }
            
            peopleList.removeAll { usr in
                usr.id == user.id
            }
        }
        
        fetchTop8()
        
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
    

  func uploadUserProfilePicture(image: UIImage, user: User) async throws -> String {
    let path = "profileImages/\(user.username)"
    
    return try await withCheckedThrowingContinuation { continuation in
        FirebaseService.shared.uploadImage(image, path: path) { result in
            switch result {
            case .success(let url):
                Task {
                    do {
                        var newUser = user
                        newUser.proPic = url
                        try await FirebaseService.shared.updateField(collection: "users", documentId: newUser.id, field: "proPic", value: url)
                        continuation.resume(returning: url)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}

func updateUserProfile(_ user: User) async throws {
    do {
        try await FirebaseService.shared.updateDocument(collection: "users", object: user)
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    } catch {
        throw error
    }
}
}
