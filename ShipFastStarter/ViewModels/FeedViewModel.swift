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
    @Published var allVotes: [Vote] = []
    @Published var allFriends: [User] = []
    @Published var allUsers: [User] = []
    @Published var userPosts: [FeedPost] = []
    @Published var visitingUser: User = User.exUser
    
    private var currentPage = 0
    private let pageSize = 20
    var hasMoreData = true

    func setInitialData(polls: [Poll], votes: [Vote], friends: [User], users: [User]) {
        self.allPolls = polls
        self.allVotes = votes
        self.allFriends = friends
        self.allUsers = users
        self.feedPosts = [] // Clear existing posts
        self.currentPage = 0 // Reset the page
        self.hasMoreData = true // Reset hasMoreData
        fetchNextPage() // Fetch the first page
    }


    func fetchVotes() async {
        do {
            let votes: [Vote] = try await FirebaseService.shared.fetchDocuments(
                collection: FirestoreCollections.votes,
                whereField: "schoolId",
                isEqualTo: currUser.schoolId
            )
            self.allVotes = votes
        } catch {
            print("Error fetching votes for user: \(error.localizedDescription)")
        }
    }


    func fetchNextPage() {
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, allPolls.count)
        let newPosts = processPollsForFeed(polls: allPolls)
        
        // Remove duplicates before appending
        let uniqueNewPosts = newPosts.filter { newPost in
            !feedPosts.contains { $0.id == newPost.id }
            
        }
        
        feedPosts.append(contentsOf: uniqueNewPosts)
        
        currentPage += 1
    }

    
    func processPollsForUserFeed() {
        var newPosts: [FeedPost] = []
        let dateFormatter = ISO8601DateFormatter()
        let sortedVotes = self.allVotes.sorted {
            return $0.createdAt > $1.createdAt
        }
        for vote in sortedVotes {
            let votedByUser = (allUsers + [self.currUser]).first(where: { $0.id == vote.voterId })
            let feedPost = FeedPost(
                id: vote.id,
                user: visitingUser,
                votedByUser: (votedByUser)!,
                aura: vote.amount,
                question: vote.question,
                pollId: vote.pollId,
                timestamp: vote.createdAt
            )
            if !newPosts.contains(where: { post in
                post.id == feedPost.id
            }) {
                newPosts.append(feedPost)
            }
        }
        
        userPosts = newPosts.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    private func processPollsForFeed(polls: [Poll]) -> [FeedPost] {
        var newPosts: [FeedPost] = []
        let sortedVotes = self.allVotes.sorted {
            return $0.createdAt > $1.createdAt
        }

        for vote in sortedVotes {
            let votedByUser = (allUsers + [self.currUser]).first(where: { $0.id == vote.voterId })
            let votedForUser = (allUsers + [self.currUser]).first(where: { $0.id == vote.votedForId })
            let feedPost = FeedPost(
                id: vote.id,
                user: votedForUser!,
                votedByUser: (votedByUser)!,
                aura: vote.amount,
                question: vote.question,
                pollId: vote.pollId,
                timestamp: vote.createdAt
            )
            if !newPosts.contains(where: { post in
                post.id == feedPost.id
            }) {
                newPosts.append(feedPost)
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
