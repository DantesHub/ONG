//
//  FeedViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/20/24.
//

import Foundation

struct FeedPost: Identifiable, Equatable, Hashable {
    let id: String
    let user: User
    let votedByUser: User
    let aura: Int
    let question: String
    let pollId: String
    let timestamp: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class FeedViewModel: ObservableObject {
    @Published var currUser: User = User.exUser
    @Published var feedPosts: [FeedPost] = []
    @Published var allPolls: [Poll] = []
    @Published var allFriends: [User] = []
    @Published var allUsers: [User] = []
    
    private var currentPage = 0
    private let pageSize = 20
    private var hasMoreData = true
    private var processedPostIds = Set<String>()

    func setInitialData(polls: [Poll], friends: [User], users: [User]) {
        self.allPolls = polls
        self.allFriends = friends
        self.allUsers = users + [currUser]
        self.currentPage = 0
        self.feedPosts.removeAll()
        self.processedPostIds.removeAll()
        self.hasMoreData = true
        fetchNextPage()
    }

    func fetchNextPage() {
        guard hasMoreData else { return }
        
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, allPolls.count)
        
        allPolls = allPolls.reversed()
        let pollsToProcess = Array(allPolls)
        let newPosts = processPollsForFeed(polls: pollsToProcess)
        
        for post in newPosts {
            if !processedPostIds.contains(post.id) {
                feedPosts.append(post)
                processedPostIds.insert(post.id)
            }
        }
        
        feedPosts.sort(by: { $0.timestamp > $1.timestamp })
        
        currentPage += 1
        hasMoreData = endIndex < allPolls.count
    }
    
    private func processPollsForFeed(polls: [Poll]) -> [FeedPost] {
        var newPosts: [FeedPost] = []
        let dateFormatter = ISO8601DateFormatter()
        
        for poll in polls {
            for option in poll.pollOptions {
                guard let votes = option.votes, !votes.isEmpty else { continue }
                
                for (voterId, voteInfo) in votes {
                    guard let votedUser = allUsers.first(where: { $0.id == option.userId }),
                          let votingUser = allUsers.first(where: { $0.id == voterId }),
                          let dateString = voteInfo["date"],
                          let aura = voteInfo["numVotes"],
                          let date = dateFormatter.date(from: dateString) else {
                        continue
                    }
                    
                    let feedPost = FeedPost(
                        id: "\(poll.id)_\(option.id)_\(voterId)",
                        user: votedUser,
                        votedByUser: votingUser,
                        aura: Int(aura) ?? 0,
                        question: poll.title,
                        pollId: poll.id,
                        timestamp: date
                    )
                    newPosts.append(feedPost)
                }
            }
        }
        
        return newPosts.sorted(by: { $0.timestamp > $1.timestamp })
    }
}
