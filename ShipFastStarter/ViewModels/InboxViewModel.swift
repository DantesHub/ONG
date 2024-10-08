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
            let userOption = PollOption(id: UUID().uuidString, type: "", option: "\(currUser?.firstName ?? "") \(currUser?.lastName ?? "")", userId: "ongteam1", votes: [:], gradeLevel: "12")
            currentFourOptions.append(userOption)
            currentFourOptions.append(PollOption.exPollOption)
            currentFourOptions.append(PollOption.exPollOption)
            currentFourOptions.append(PollOption.exPollOption)
        } else {
            if let option = selectedPollOption, let poll = selectedPoll {
                currentFourOptions = [option]
                
                // Get the other options that aren't the selected one
                let otherOptions = poll.pollOptions.filter { $0.id != option.id }
                
                // Shuffle the other options and take the first three
                let additionalOptions = Array(otherOptions.shuffled().prefix(3))
                
                // Add these options to currentFourOptions
                currentFourOptions.append(contentsOf: additionalOptions)
                
                // If we don't have 4 options yet (in case there weren't 3 other options),
                // pad with the selected option
                while currentFourOptions.count < 4 {
                    currentFourOptions.append(option)
                }
            }
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
    func fetchNotifications(for user: User) {
        do {
//            let polls: [Poll] = try await FirebaseService.shared.fetchDocuments(
//                collection: "polls",
//                whereField: "schoolId",
//                isEqualTo: user.schoolId
//            )
//            
            var newNotifs: [(PollOption, Date)] = []
            var pastNotifs: [(PollOption, Date)] = []
            var newVotes: [InboxItem] = []
            var oldVotes: [InboxItem] = []
            allUsers.append(User.exUser)
            
            
            for poll in allPolls {
                for option in poll.pollOptions {
                    if option.userId == user.id && !(option.votes?.isEmpty ?? true) {
                        if let votes = option.votes {
                            for (voterId, voteInfo) in votes {
                                
                                if let usr = allUsers.first(where: { usrInSchool in
                                    usrInSchool.id == voterId
                                }) {
                                    if let dateStr = voteInfo["date"],
                                       let numVotes = voteInfo["numVotes"],
                                       let date = ISO8601DateFormatter().date(from: dateStr) {
                                        var notificationStatus = false
                                        let viewdIds = UserDefaults.standard.array(forKey: Constants.viewedNotificationIds) as? [String] ?? []
                                        if viewdIds.contains(where: { id in
                                            id == poll.id
                                        }) {
                                            notificationStatus = true
                                        } else {
                                            notificationStatus = voteInfo["viewedNotification"] == "false"
                                        }
                                        let newInboxItem = InboxItem(
                                            id: UUID().uuidString,
                                            userId: voterId,
                                            firstName: usr.firstName,
                                            aura: Int(numVotes) ?? 1,
                                            time: date,
                                            gender: usr.gender,
                                            grade: usr.grade,
                                            backgroundColor: Color(usr.color),
                                            accompanyingPoll: poll,
                                            pollOption: option,
                                            isNew: notificationStatus,
                                            shields: usr.shields
                                        )
                                        if voteInfo["viewedNotification"] == "false" {
                                            newVotes.append(newInboxItem)
//                                            if !newNotifs.contains(where: { $0.0.id == option.id }) {
//                                                newNotifs.append((option, date))
//                                            }
                                        } else {
                                            oldVotes.append(newInboxItem)
//                                            if !pastNotifs.contains(where: { $0.0.id == option.id }) {
//                                                pastNotifs.append((option, date))
//                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
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
        guard var selectedPoll = selectedPoll,
              let selectedPollOption = selectedPollOption,
              let selectedInbox = selectedInbox else {
            print("Error: Selected poll, option, or inbox item is nil")
            return
        }

        // Update local data
        if let index = selectedPoll.pollOptions.firstIndex(where: { $0.id == selectedPollOption.id }) {
            if var votes = selectedPoll.pollOptions[index].votes {
                if var userVote = votes[selectedInbox.userId] {
                    userVote["viewedNotification"] = "true"
                    // Do not modify the date at all
                    votes[selectedInbox.userId] = userVote
                    selectedPoll.pollOptions[index].votes = votes

                    // Update Firebase
                    do {
                        try await FirebaseService.shared.updateDocument(
                            collection: "polls",
                            object: selectedPoll
                        )

                        // Update local lists
                        if let newIndex = newUsersWhoVoted.firstIndex(where: { $0.id == selectedInbox.id }) {
                            let movedItem = newUsersWhoVoted.remove(at: newIndex)
                            oldUsersWhoVoted.append(movedItem)
                            oldUsersWhoVoted.sort { $0.time > $1.time }
                        }

//                        if let newNotificationIndex = newNotifications.firstIndex(where: { $0.id == selectedPollOption.id }) {
//                            let movedNotification = newNotifications.remove(at: newNotificationIndex)
//                            pastNotifications.append(movedNotification)
//                        }

                        // Update the published selectedPoll
                        self.selectedPoll = selectedPoll

                        print("View status updated successfully")
                    } catch {
                        print("Error updating view status in Firebase: \(error.localizedDescription)")
                    }
                } else {
                    print("Error: User vote not found")
                }
            } else {
                print("Error: Votes dictionary is nil")
            }
        } else {
            print("Error: Selected poll option not found in poll")
        }
    }
    
    @MainActor
    func fetchUser(id: String) async -> User? {
        do {
//            let users: [User] = try await FirebaseService.getFilteredDocuments(collection: "users", filterField: "id", filterValue: id)
            let user: User = try await FirebaseService.shared.getDocument(collection: "users", documentId: id)
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
//            try await FirebaseService.shared.updateDocument(collection: "users", object: currUser)
            try await FirebaseService.shared.updateFields(collection: "users", documentId: currUser.id, fields: fieldsToUpdate)
            try await FirebaseService.shared.updateField(collection: "users", documentId: updatedRequestedUser.id, field: "friends", value: updatedRequestedUser.friends)
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
            try await FirebaseService.shared.updateField(collection: "users", documentId: currUser.id, field: "friendRequests", value: currUser.friendRequests)
            try await FirebaseService.shared.updateField(collection: "users", documentId: updatedRequestedUser.id, field: "friends", value: updatedRequestedUser.friends)
        } catch {
            print(error.localizedDescription)
        }
    }
}
