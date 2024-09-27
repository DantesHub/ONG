//
//  FeedViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/20/24.
//

import Foundation

struct FeedPost: Identifiable, Equatable {
    let id: String
    let user: User
    let votedByUser: User
    let aura: Int
    let question: String
    let pollId: String
    let timestamp: Date
}

class FeedViewModel: ObservableObject {
    @Published var currUser: User = User.exUser
    @Published var feedPosts: [FeedPost] = []
    @Published var allPolls: [Poll] = []
    @Published var allFriends: [User] = []
    @Published var allUsers: [User] = []
    @Published var userPosts: [FeedPost] = []
    @Published var visitingUser: User = User.exUser
    
    private var currentPage = 0
    private let pageSize = 20
    var hasMoreData = true

    func setInitialData(polls: [Poll], friends: [User], users: [User]) {
        self.allPolls = polls
        self.allFriends = friends
        self.allUsers = users
        self.feedPosts = [] // Clear existing posts
        self.currentPage = 0 // Reset the page
        self.hasMoreData = true // Reset hasMoreData
        fetchNextPage() // Fetch the first page
    }

    func fetchNextPage() {
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, allPolls.count)
        
//        if startIndex >= endIndex {
//            hasMoreData = false
//            return
//        }
        
        let pollsToProcess = Array(allPolls[startIndex..<endIndex])
        let newPosts = processPollsForFeed(polls: allPolls)
        
        // Remove duplicates before appending
        let uniqueNewPosts = newPosts.filter { newPost in
            !feedPosts.contains { $0.id == newPost.id }
            
        }
        
        feedPosts.append(contentsOf: uniqueNewPosts)
        
        currentPage += 1
//        hasMoreData = endIndex < allPolls.count
    }

    
    func processPollsForUserFeed() {
        var newPosts: [FeedPost] = []
        let dateFormatter = ISO8601DateFormatter()
        
        for poll in allPolls {
            for option in poll.pollOptions {
                // Check if the option corresponds to the visiting user and has votes
                if option.userId == visitingUser.id, let votes = option.votes, !votes.isEmpty {
                    // Sort votes by date (most recent first)
                    let sortedVotes = votes.sorted {
                        guard let date1 = dateFormatter.date(from: $0.value["date"] ?? ""),
                              let date2 = dateFormatter.date(from: $1.value["date"] ?? "") else {
                            return false
                        }
                        return date1 > date2
                    }
                    
                    for (voterId, voteInfo) in sortedVotes {
                        guard let votingUser = allUsers.first(where: { $0.id == voterId }),
                              let dateString = voteInfo["date"],
                              let aura = voteInfo["numVotes"],
                              let date = dateFormatter.date(from: dateString) else {
                            continue
                        }
                        
                        let feedPost = FeedPost(
                            id: "\(poll.id)_\(option.id)_\(voterId)",
                            user: visitingUser,
                            votedByUser: votingUser,
                            aura: Int(aura) ?? 0,
                            question: poll.title,
                            pollId: poll.id,
                            timestamp: date
                        )
                        if !newPosts.contains(where: { post in
                            post.id == feedPost.id
                        }) {
                            newPosts.append(feedPost)
                        }
                    }
                }
            }
        }
        
        userPosts = newPosts.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    private func processPollsForFeed(polls: [Poll]) -> [FeedPost] {
        var newPosts: [FeedPost] = []
        let dateFormatter = ISO8601DateFormatter()
//        allUsers.append(currUser)
        
        for poll in polls {
            for option in poll.pollOptions {
                guard let votes = option.votes, !votes.isEmpty else { continue }
                let sortedVotes = votes.sorted {
                    guard let date1 = dateFormatter.date(from: $0.value["date"] ?? ""),
                          let date2 = dateFormatter.date(from: $1.value["date"] ?? "") else {
                        return false
                    }
                    return date1 > date2
                }
                
                for (voterId, voteInfo) in sortedVotes {
                    guard let votedUser = allUsers.first(where: { $0.id == option.userId }),
                          let votingUser = allUsers.first(where: { $0.id == voterId }),
                          let dateString = voteInfo["date"],
                          let aura = voteInfo["numVotes"],
                          let date = dateFormatter.date(from: dateString) else {
                        continue
                    }
                    
                    var newAura = 0
                    if Int(aura) ?? 0 < 103 {
                        newAura = 100
                    } else {
                        newAura = Int(aura) ?? 0
                    }
                    
                    let feedPost = FeedPost(
                        id: "\(poll.id)_\(option.id)_\(voterId)", // Create a unique ID
                        user: votedUser,
                        votedByUser: votingUser,
                        aura: newAura,
                        question: poll.title,
                        pollId: poll.id,
                        timestamp: date
                    )
                    if !newPosts.contains(where: { post in
                        post.id == feedPost.id
                    }) {
                        newPosts.append(feedPost)
                    }
                }
            }
        }
        
        return newPosts.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    // Updated groupedFeedPosts
        var groupedFeedPosts: [(key: String, posts: [FeedPost])] {
            let calendar = Calendar.current
            let now = Date()

            let grouped = Dictionary(grouping: feedPosts) { post -> String in
                let components = calendar.dateComponents([.day], from: post.timestamp, to: now)

                if let day = components.day, day > 0 {
                    if day == 1 {
                        return "Yesterday"
                    } else if day < 7 {
                        return "This Week"
                    } else {
                        return "Past"
                    }
                } else {
                    return "Today"
                }
            }

            let order = ["Today", "Yesterday", "This Week", "Past"]
            return order.compactMap { key in
                if let posts = grouped[key] {
                    return (key: key, posts: posts)
                } else {
                    return nil
                }
            }
        }
}
