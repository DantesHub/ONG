import Foundation
import UIKit
import FirebaseAuth

class ProfileViewModel: ObservableObject, ImageUploadable {
    @Published var profileImage: UIImage?
    @Published var peopleList: [User] = []
    @Published var friends: [User] = []
    @Published var visitedUser: User?
    @Published var isVisitingUser: Bool = false
    @Published var isCrush: Bool = false
    @Published var isFriend: Bool = false
    @Published var showFriendsScreen: Bool = false
    @Published var showingImagePicker = false
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var editProfile: Bool = false
    @Published var topEight: [User] = []
    @Published var currentUser: User?
    @Published var showOtherProfile = false
    init() {
        
    }
    
    func fetchTop8() {
        DispatchQueue.main.async {
            self.topEight = self.peopleList.sorted(by: { user1, user2 in
                user1.aura > user2.aura
            })
        }
    }

    func addFriends(currUser: User, users: [User]) async -> User {
        // we have to update each document separately
        var newUser = currUser
        var newFriends: [User] = []
        for friend in users {
            var newFriend = friend
            newUser.friends[friend.id] = Date().toString(format: "yyyy-MM-dd HH:mm:ss")
            newFriend.friendRequests[newUser.id] = Date().toString(format: "yyyy-MM-dd HH:mm:ss")
            
            do {
                try await FirebaseService.shared.updateField(collection: FirestoreCollections.users, documentId: newFriend.id, field: "friendRequests", value: newFriend.friendRequests)
            } catch {
                print(error.localizedDescription)
            }
            
            newFriends.append(newFriend)
        }
        newFriends.append(newUser)
        
        do {
            try await FirebaseService.shared.updateField(collection: FirestoreCollections.users, documentId: currUser.id, field: "friends", value: newUser.friends)
        } catch {
            print(error.localizedDescription)
        }
        
        // Update any @Published properties if needed
        // For example, if you need to update `self.currentUser`, ensure it's done on the main thread
        DispatchQueue.main.async {
            self.currentUser = newUser
        }
        
        return newUser
    }
    
    // MARK: - visiting profile functions
    func tappedAdd(currUser: User, friend: User, currentStatus: String) async -> User {
        var newUser = currUser
        // fetch other user
        var selectedFriend = friend
        // determine status of friendship
        // check if it exists inside user's friends dictionary
        if newUser.friends.contains(where: { k, _ in
            k == friend.id
        }) {
            // Update status, if friend is in dictionary means they either sent friend request or are friends
            
            if let _ = newUser.friends[friend.id] {
                if selectedFriend.friendRequests.contains(where: { k, _ in
                    k == newUser.id // "Sent 💌" status
                }) {
                    // We need to remove request from friendRequests
                    selectedFriend.friendRequests.removeValue(forKey: currUser.id)
                    newUser.friends.removeValue(forKey: friend.id)
                } else if selectedFriend.friends.contains(where: { k, _ in
                    k == newUser.id // They are friends ✅, we need to unfriend
                }) {
                    selectedFriend.friends.removeValue(forKey: currUser.id)
                    // We need to remove friend from user's friends
                    newUser.friends.removeValue(forKey: friend.id)
                } else { // The friend declined the user's request, so we need to show "+ Add" status
                    newUser.friends[friend.id] = "Sent 💌"
                    // Update other user's friendRequests property with timestamp
                    selectedFriend.friendRequests[currUser.id] = "\(Date().toString(format: "yyyy-MM-dd HH:mm:ss"))"
                }
            }
        } else { // Append friend to dictionary
            newUser.friends[friend.id] = "Sent 💌"
            // Update other user's friendRequests property with timestamp
            selectedFriend.friendRequests[currUser.id] = "\(Date().toString(format: "yyyy-MM-dd HH:mm:ss"))"
        }
        
        do {
            try await FirebaseService.shared.updateDocument(collection: FirestoreCollections.users, object: newUser)
            try await FirebaseService.shared.updateDocument(collection: FirestoreCollections.users, object: selectedFriend)
        } catch {
            print(error.localizedDescription)
        }
        
        // Update the peopleList on the main thread
        DispatchQueue.main.async {
            if let index = self.peopleList.firstIndex(where: { $0.id == selectedFriend.id }) {
                self.peopleList[index] = selectedFriend
            }
        }
        
        return newUser
    }
    
    
    func loadImages() async {
        // Preload profile images
        let imageUrls = peopleList.compactMap { URL(string: $0.proPic) }
        await ImageCache.shared.preloadImages(urls: imageUrls)
    }

    func fetchPeopleList(user: User) async {
        DispatchQueue.main.async {
            self.peopleList = []
        }
        do {
            let fetchedPeopleList: [User] = try await FirebaseService.shared.fetchDocuments(collection: FirestoreCollections.users, whereField: "schoolId", isEqualTo: user.schoolId)
            var updatedPeopleList = fetchedPeopleList
            var updatedFriends = self.friends
            
            // Need to determine if they are friends already, also need to determine if we sent friend request
            for (index, person) in updatedPeopleList.enumerated() {
                var newPerson = person
       
                if newPerson.friendRequests.keys.contains(user.id) {
                    newPerson.friendsStatus =  "Sent 💌"
                } else if newPerson.friends.contains(where: { k, _ in
                    k == user.id  // They are friends ✅
                }) && !newPerson.friendRequests.contains(where: { k, _ in
                    k == user.id
                }) && user.friends.contains(where: { k, _ in
                    k == newPerson.id }) {
                    newPerson.friendsStatus =  "Friends ✅"
                    if !updatedFriends.contains(where: { usr in
                        usr.id == newPerson.id
                    }) {
                        updatedFriends.append(newPerson)
                    }
                } else { // The friend declined the user's request, so we need to show "+ Add" status
                    newPerson.friendsStatus =  "Add +"
                }
           
                updatedPeopleList[index] = newPerson
            }
            
            // Remove current user from the list
            updatedPeopleList.removeAll { usr in
                usr.id == user.id
            }
            
            // Update @Published properties on the main thread
            DispatchQueue.main.async {
                self.peopleList = updatedPeopleList
                self.friends = updatedFriends
            }
            self.fetchTop8()
            
            
            await loadImages()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchUserProfile(id: String) {
        // Implement if needed
    }

    func fetchUserProfilePicture(user: User) {
//        guard let _ = Auth.auth().currentUser else {
//            print("No authenticated user")
//            return
//        }
//        
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
                            try await FirebaseService.shared.updateField(collection: FirestoreCollections.users, documentId: newUser.id, field: "proPic", value: url)
                            DispatchQueue.main.async {
                                self.currentUser = newUser
                            }
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
            try await FirebaseService.shared.updateDocument(collection: FirestoreCollections.users, object: user)
            DispatchQueue.main.async {
                self.currentUser = user
            }
        } catch {
            throw error
        }
    }
}
