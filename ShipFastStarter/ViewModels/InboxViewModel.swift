//
//  InboxViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/6/24.
//

import Foundation
import FirebaseFirestore
import SwiftUI

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
            // Fetch polls where the user is mentioned in pollOptions
            let polls: [Poll] = try await FirebaseService.shared.fetchDocuments(
                collection: "polls",
                whereField: "schoolId",
                isEqualTo: user.schoolId
            )
            
            let (new, past) = polls.reduce(into: ([PollOption](), [PollOption]())) { result, poll in
                for option in poll.pollOptions {
                    if option.userId == user.id && !(option.votes?.isEmpty ?? true) {
                        if let votes = option.votes {
                            for (voterId, voteInfo) in votes {
                                if voteInfo["viewedNotification"] == "false" {
                                    result.0.append(option)
                                } else {
                                    result.1.append(option)
                                }
                                
                                Task {
                                    if let usr = await fetchUser(id: voterId) {
                                        if let dateStr = voteInfo["date"],
                                           let numVotes = voteInfo["numVotes"],
                                           let date = ISO8601DateFormatter().date(from: dateStr) {
                                            let newInboxItem = InboxItem(
                                                id: voterId,
                                                firstName: usr.firstName,
                                                aura: Int(numVotes) ?? 1,
                                                time: date,
                                                gender: usr.gender,
                                                grade: usr.grade,
                                                backgroundColor: Color(hex: usr.color),
                                                accompanyingPoll: poll,
                                                pollOption: option
                                            )
                                            if voteInfo["viewedNotification"] == "false" {
                                                await MainActor.run {
                                                    self.newUsersWhoVoted.append(newInboxItem)
                                                }
                                            } else {
                                                await MainActor.run {
                                                    self.oldUsersWhoVoted.append(newInboxItem)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Update published properties
            await MainActor.run {
                self.newNotifications = new
                self.pastNotifications = past
            }
            
        } catch {
            print("Error fetching notifications: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func fetchUser(id: String) async -> User? {
        do {
//            let users: [User] = try await FirebaseService.getFilteredDocuments(collection: "users", filterField: "id", filterValue: id)
            let user: User = try await FirebaseService.shared.getDocument(collection: "users", documentId: id)
            return user
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
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
}
