//
//  InboxViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/6/24.
//

import Foundation
import FirebaseFirestore

class InboxViewModel: ObservableObject {
    @Published var tappedNotification: Bool = false
    @Published var selectedVote: Poll?
    @Published var pastNotifications: [PollOption] = []
    @Published var newNotifications: [PollOption] = []

    @MainActor
    func fetchNotifications(for user: User) async {
        do {
            // Fetch polls where the user is mentioned in pollOptions
            let polls: [Poll] = try await FirebaseService.shared.fetchDocuments(
                collection: "polls",
                whereField: "schoolId",
                isEqualTo: user.schoolId
            )
            
            let relevantOptions = polls.flatMap { poll -> [PollOption] in
                return poll.pollOptions.filter { option in
                    option.userId == user.id && !(option.votes?.isEmpty ?? true)
                }
            }
            
            
            
            // Sort options by vote timestamp (assuming the most recent vote is the one we're interested in)
            let sortedOptions = relevantOptions.sorted { (option1, option2) -> Bool in
                let timestamp1 = option1.votes?.values.compactMap { $0.keys.first }.max() ?? ""
                let timestamp2 = option2.votes?.values.compactMap { $0.keys.first }.max() ?? ""
                return timestamp1 > timestamp2
            }
            
            // Separate into new and past notifications
            let twentyFourHoursAgo = Date().addingTimeInterval(-24 * 60 * 60)
            let (new, past) = sortedOptions.reduce(into: ([PollOption](), [PollOption]())) { result, option in
                if let latestVoteTimestamp = option.votes?.values.compactMap({ $0.keys.first }).max(),
                   let date = ISO8601DateFormatter().date(from: latestVoteTimestamp),
                   date > twentyFourHoursAgo {
                    result.0.append(option)
                } else {
                    result.1.append(option)
                }
            }
            
            // Update published properties
            DispatchQueue.main.async {
                self.newNotifications = new
                self.pastNotifications = past
            }
            
        } catch {
            print("Error fetching notifications: \(error.localizedDescription)")
        }
    }
//
//    func tappedNotification() {
//        // update viewedNotification in firebase 
//    }
}
