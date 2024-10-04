//
//  InboxViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/6/24.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct FriendRequest: Identifiable {
    let id: String
    var user: User
    let time: Date
    
    static var exRequest = FriendRequest(id: UUID().uuidString, user: User.exUser, time: Date())
}

@MainActor
class InboxViewModel: ObservableObject {
    @Published var tappedNotification: Bool = false
    @Published var selectedPoll: Poll?
    @Published var selectedVote: Vote?
    @Published var selectedPollOption: PollOption?
    @Published var selectedInbox: InboxItem?
    @Published var oldUsersWhoVoted: [InboxItem] = []
    @Published var newUsersWhoVoted: [InboxItem] = []
    @Published var currentFourOptions: [PollOption] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var allPolls: [Poll] = []
    @Published var allUsers: [User] = []
    @Published var currUser: User?


    func tappedNotificationRow() {
        if selectedInbox?.userId == "ongteam" {
            currentFourOptions = []
            let userOption = PollOption(id: UUID().uuidString, type: "", option: "\(currUser?.firstName ?? "") \(currUser?.lastName ?? "")", userId: "ongteam1", gradeLevel: "12")
            currentFourOptions.append(userOption)
            currentFourOptions.append(PollOption.exPollOption)
            currentFourOptions.append(PollOption.exPollOption)
            currentFourOptions.append(PollOption.exPollOption)
        } else {
            currentFourOptions = []
            for option in selectedVote!.pollOptions {
                currentFourOptions.append(
                    PollOption(
                        id: UUID().uuidString,
                        type: "",
                        option: option,
                        userId: "ongteam1",
                        gradeLevel: "12"
                    )
                )
            }
            // currentFourOptions = selectedVote.pollOptions
        }
    }
    
    func fetchFriendRequests(for user: User) {
        friendRequests = []
        for friendRequest in user.friendRequests {
            // fetch friend
            if friendRequests.contains(where: { $0.user.id == friendRequest.key }) {
                continue
            }
            
            // why is that it only works the second time ?
            if let friend = allUsers.first(where: { usr in
                usr.id == friendRequest.key
            }) {
                print(friend.firstName, "ik")
                let timeStamp = Date.fromString((user.friendRequests[friend.id] ?? "")) ?? Date()
                let request = FriendRequest(id: UUID().uuidString, user: friend, time: timeStamp)
                if !friendRequests.contains(where: { req in
                    req.user.id == request.user.id
                }) {
                    friendRequests.append(request)
                    print(friendRequests.count, user.friendRequests.count, "gyamazawa")
                }
            }
            // request
        }
    }
    
    @MainActor
    func fetchNotifications(for user: User) async {
        do {
//          
            var newVotes: [InboxItem] = []
            var oldVotes: [InboxItem] = []
            allUsers.append(User.exUser)

            // get new votes where notificationViewed is false, sorted by date
            let votes: [Vote] = try await FirebaseService.shared.fetchDocuments(
                collection: FirestoreCollections.votes,
                whereField: "votedForId",
                isEqualTo: user.id
            )

            let newNotifs = votes.filter { $0.viewedNotification == false }
            let pastNotifs = votes.filter { $0.viewedNotification == true }
            for vote in votes {
                guard let user = allUsers.first(where: { $0.id == vote.voterId }),
                      let poll = allPolls.first(where: { $0.id == vote.pollId }) else {
                    print("Warning: Couldn't find user or poll for vote \(vote.id)")
                    continue
                }

                let inboxItem = InboxItem(
                    id: vote.id,
                    userId: user.id,
                    firstName: user.firstName,
                    aura: vote.amount,
                    time: vote.createdAt,
                    gender: user.gender,
                    grade: user.grade,
                    backgroundColor: Color(user.color),
                    accompanyingPoll: poll,
                    accompanyingVote: vote,
                    isNew: !vote.viewedNotification,
                    shields: user.shields
                )

                if vote.viewedNotification {
                    oldVotes.append(inboxItem)
                } else {
                    newVotes.append(inboxItem)
                }
                
            }

            print(newVotes.count, oldVotes.count, "you can fly again", allPolls.count)

            newVotes.sort { $0.time > $1.time }
            oldVotes.sort { $0.time > $1.time }
            
            self.newUsersWhoVoted = newVotes
            self.oldUsersWhoVoted = oldVotes

            if !UserDefaults.standard.bool(forKey: Constants.sawThisInboxItem) {
                newUsersWhoVoted.append(InboxItem.exInboxItem)
            } else {
                var newItem = InboxItem.exInboxItem
                newItem.isNew = false
                self.oldUsersWhoVoted.append(newItem)
            }
            
        } catch {
            print("Error fetching notifications: \(error.localizedDescription)")
        }
        
        fetchFriendRequests(for: user)
    }
    
    func updateViewStatus() async {
        guard var selectedVote = selectedVote,
              let selectedInbox = selectedInbox else {
            print("Error: Selected poll, option, or inbox item is nil")
            return
        }

        
        let voteRef = Firestore.firestore().collection(FirestoreCollections.votes).document(selectedInbox.accompanyingVote.id)
        do {
            try await voteRef.updateData(["viewedNotification": true])
        } catch {
            print("Error updating vote: \(error.localizedDescription)")
            // Handle the error appropriately
        }

        // Update local data
//         if let index = selectedPoll.pollOptions.firstIndex(where: { $0.id == selectedPollOption.id }) {
//             if var votes = selectedPoll.pollOptions[index].votes {
//                 if var userVote = votes[selectedInbox.userId] {
//                     userVote["viewedNotification"] = "true"
//                     // Do not modify the date at all
//                     votes[selectedInbox.userId] = userVote
//                     selectedPoll.pollOptions[index].votes = votes

//                     // Update Firebase
//                     do {
//                         try await FirebaseService.shared.updateDocument(
//                             collection: FirestoreCollections.polls,
//                             object: selectedPoll
//                         )

//                         // Update local lists
//                         if let newIndex = newUsersWhoVoted.firstIndex(where: { $0.id == selectedInbox.id }) {
//                             let movedItem = newUsersWhoVoted.remove(at: newIndex)
//                             oldUsersWhoVoted.append(movedItem)
//                             oldUsersWhoVoted.sort { $0.time > $1.time }
//                         }

// //                        if let newNotificationIndex = newNotifications.firstIndex(where: { $0.id == selectedPollOption.id }) {
// //                            let movedNotification = newNotifications.remove(at: newNotificationIndex)
// //                            pastNotifications.append(movedNotification)
// //                        }

//                         // Update the published selectedPoll
//                         self.selectedPoll = selectedPoll

//                         print("View status updated successfully")
//                     } catch {
//                         print("Error updating view status in Firebase: \(error.localizedDescription)")
//                     }
//                 } else {
//                     print("Error: User vote not found")
//                 }
//             } else {
//                 print("Error: Votes dictionary is nil")
//             }
//         } else {
//             print("Error: Selected poll option not found in poll")
//         }
    }
    
    @MainActor
    func fetchUser(id: String) async -> User? {
        do {
//            let users: [User] = try await FirebaseService.getFilteredDocuments(collection: FirestoreCollections.users, filterField: "id", filterValue: id)
            let user: User = try await FirebaseService.shared.getDocument(collection: FirestoreCollections.users, documentId: id)
            return user
        } catch {
            print("Error fetching user \(id): \(error.localizedDescription)")
        }
        return nil
    }

    

            
    //MARK: - Friend requests
    func tappedAcceptFriendRequest(currUser: User, requestedUser: User) async {
 
        var updatedRequestedUser = requestedUser
        updatedRequestedUser.friends[currUser.id] = Date().toString()
        friendRequests.removeAll { req in
            req.user.id == requestedUser.id
        }
        var fieldsToUpdate = ["friendRequests": currUser.friendRequests, "friends": currUser.friends]
        do {
//            try await FirebaseService.shared.updateDocument(collection: FirestoreCollections.users, object: currUser)
            try await FirebaseService.shared.updateFields(collection: FirestoreCollections.users, documentId: currUser.id, fields: fieldsToUpdate)
            try await FirebaseService.shared.updateField(collection: FirestoreCollections.users, documentId: updatedRequestedUser.id, field: "friends", value: updatedRequestedUser.friends)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func tappedDeclineFriendRequest(currUser: User, requestedUser: User) async {
        var updatedRequestedUser = requestedUser
        updatedRequestedUser.friends.removeValue(forKey: currUser.id)

        friendRequests.removeAll { req in
            req.user.id == requestedUser.id
        }
        // update in firebase
        do {
            try await FirebaseService.shared.updateField(collection: FirestoreCollections.users, documentId: currUser.id, field: "friendRequests", value: currUser.friendRequests)
            try await FirebaseService.shared.updateField(collection: FirestoreCollections.users, documentId: updatedRequestedUser.id, field: "friends", value: updatedRequestedUser.friends)
        } catch {
            print(error.localizedDescription)
        }
    }
}



