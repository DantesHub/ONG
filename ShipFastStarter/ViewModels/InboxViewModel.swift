//
//  InboxViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/6/24.
//

import Foundation
import FirebaseFirestore
import SwiftUI

@MainActor
class InboxViewModel: ObservableObject {
    @Published var tappedNotification: Bool = false
    @Published var selectedPoll: Poll?
    @Published var selectedPollOption: PollOption?
    @Published var selectedInbox: InboxItem?
    @Published var pastNotifications: [PollOption] = []
    @Published var newNotifications: [PollOption] = []
    @Published var oldUsersWhoVoted: [InboxItem] = []
    @Published var newUsersWhoVoted: [InboxItem] = []
    @Published var currentFourOptions: [PollOption] = []
    
    func tappedNotificationRow() {
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
    
    @MainActor
    func fetchNotifications(for user: User) async {
        do {
            let polls: [Poll] = try await FirebaseService.shared.fetchDocuments(
                collection: "polls",
                whereField: "schoolId",
                isEqualTo: user.schoolId
            )
            
            var newNotifs: [(PollOption, Date)] = []
            var pastNotifs: [(PollOption, Date)] = []
            var newVotes: [InboxItem] = []
            var oldVotes: [InboxItem] = []
            
            for poll in polls {
                for option in poll.pollOptions {
                    if option.userId == user.id && !(option.votes?.isEmpty ?? true) {
                        if let votes = option.votes {
                            for (voterId, voteInfo) in votes {
                                if let usr = await fetchUser(id: voterId) {
                                    if let dateStr = voteInfo["date"],
                                       let numVotes = voteInfo["numVotes"],
                                       let date = ISO8601DateFormatter().date(from: dateStr) {
                                        print(dateStr, "facetime", date, Date())
                                        let newInboxItem = InboxItem(
                                            id: UUID().uuidString,
                                            userId: voterId,
                                            firstName: usr.firstName,
                                            aura: Int(numVotes) ?? 1,
                                            time: date,
                                            gender: usr.gender,
                                            grade: usr.grade,
                                            backgroundColor: Color(hex: usr.color),
                                            accompanyingPoll: poll,
                                            pollOption: option,
                                            isNew: voteInfo["viewedNotification"] == "false"
                                        )
                                        if voteInfo["viewedNotification"] == "false" {
                                            newVotes.append(newInboxItem)
                                            if !newNotifs.contains(where: { $0.0.id == option.id }) {
                                                newNotifs.append((option, date))
                                            }
                                        } else {
                                            oldVotes.append(newInboxItem)
                                            if !pastNotifs.contains(where: { $0.0.id == option.id }) {
                                                pastNotifs.append((option, date))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Sort everything by date
            newNotifs.sort { $0.1 > $1.1 }
            pastNotifs.sort { $0.1 > $1.1 }
            newVotes.sort { $0.time > $1.time }
            oldVotes.sort { $0.time > $1.time }
            
            // Update published properties
            self.newNotifications = newNotifs.map { $0.0 }
            self.pastNotifications = pastNotifs.map { $0.0 }
            self.newUsersWhoVoted = newVotes
            self.oldUsersWhoVoted = oldVotes
            
        } catch {
            print("Error fetching notifications: \(error.localizedDescription)")
        }
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

                        if let newNotificationIndex = newNotifications.firstIndex(where: { $0.id == selectedPollOption.id }) {
                            let movedNotification = newNotifications.remove(at: newNotificationIndex)
                            pastNotifications.append(movedNotification)
                        }

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

    
   func formatRelativeTime(from date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return year == 1 ? "1 year ago" : "\(year) years ago"
        }
        
        if let month = components.month, month > 0 {
            return month == 1 ? "1 month ago" : "\(month) months ago"
        }
        
        if let day = components.day, day > 0 {
            if day == 1 {
                return "yesterday"
            } else if day < 7 {
                return "\(day)d ago"
            } else {
                let weeks = day / 7
                return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
            }
        }
        
        if let hour = components.hour, hour > 0 {
            if hour == 1 {
                
            }
            if hour < 24 {
                return "\(hour)h ago"
            }

        }
        
        if let minute = components.minute, minute > 0 {
            if minute < 60 {
                return "\(minute)m ago"
            }
        }
        
        if let second = components.second, second > 0 {
            if second < 60 {
                return "just now"
            }
        }
        
        return "just now"
    }
    
    //MARK: - Friend requests
    func tappedAcceptFriendRequest() {
        
    }
    
    func tappedDeclineFriendRequest() {
        
    }
}
