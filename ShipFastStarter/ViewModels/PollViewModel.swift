//
//  PollViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import Foundation
import FirebaseFirestore

@MainActor
class PollViewModel: ObservableObject {
    @Published var pollSet: [Poll] = [Poll.exPoll]
    @Published var allPolls: [Poll] = [Poll.exPoll]
    @Published var selectedPoll: Poll = Poll.exPoll
    @Published var currentOptions: [PollOption] = []
    @Published var currentFourOptions: [PollOption] = []
    @Published var showProgress: Bool = false
    @Published var animateProgress: Bool = false
    @Published var animateAllOptions: Bool = false
    @Published var questionEmoji: String = ""
    
    private var currentOptionIndex: Int = 0
    
    init() {      
        updateQuestionEmoji() 
    }

    func fetchPolls(for user: User) async {
        do {
            let polls: [Poll] = try await FirebaseService.shared.fetchDocuments(
                collection: "polls",
                whereField: "schoolId",
                isEqualTo: user.schoolId
            )
            self.allPolls = polls
            self.pollSet = polls.filter { poll in
                !poll.usersWhoVoted.contains(user.id)
            }
            self.pollSet.sort { $0.createdAt > $1.createdAt }
            if let first = self.pollSet.first {
                self.selectedPoll = first
                await self.getPollOptions()
            }
        } catch {
            print("Error fetching polls: \(error.localizedDescription)")
        }
    }

    func answerPoll(user: User, option: PollOption, totalVotes: Int) async {
        // Immediately update local state
        var finalOption = PollOption.exPollOption
        if var updatedOption = currentFourOptions.first(where: { $0.id == option.id }) {
            var updatedVotes = updatedOption.votes ?? [:]
            updatedVotes[user.id] = (updatedVotes[user.id] ?? 0) + 1
            updatedOption.votes = updatedVotes
            finalOption = updatedOption 
            if let index = currentFourOptions.firstIndex(where: { $0.id == option.id }) {
                currentFourOptions[index] = updatedOption
            }
        }
        showProgress = true
        animateProgress = true
        animateAllOptions = true
        
        // Perform Firebase updates in the background
        Task {
            do {
                // Update the poll option in Firestore
                try await FirebaseService.shared.updateDocument(
                    collection: "pollOptions",
                    object: finalOption
                )

                // Update the user's votedPolls
                var updatedUser = user
                updatedUser.votedPolls.append(selectedPoll.id)
                try await FirebaseService.shared.updateDocument(
                    collection: "users",
                    object: updatedUser
                )
                
                // Update the poll's usersWhoVoted
                var updatedPoll = selectedPoll
                updatedPoll.usersWhoVoted.append(user.id)
                try await FirebaseService.shared.updateDocument(
                    collection: "polls",
                    object: updatedPoll
                )
                selectedPoll = updatedPoll
                
                // Don't move to the next poll automatically
                // Wait for user to tap to continue
            } catch {
                print("Error answering poll: \(error.localizedDescription)")
            }                     
        }
    }

    func createPoll(user: User) async {
        var potentialQuestions = Question.allQuestions.filter { question in
            !allPolls.contains { $0.title == question.question }
        }

        var newPolls: [Poll] = []
        var newOptions: [PollOption] = []

        while newPolls.count < 8 && !potentialQuestions.isEmpty {
            if let question = potentialQuestions.first {
                potentialQuestions.removeFirst()
                let users = try? await FirebaseService.shared.fetchDocuments(
                    collection: "users",
                    whereField: "schoolId",
                    isEqualTo: user.schoolId
                ) as [User]
                let id = UUID().uuidString
                selectedPoll.id = id
                let options = createOptions(users: users ?? [])
                let poll = Poll(
                    id: id,
                    title: question.question,
                    createdAt: Date(),
                    pollOptions: options.map { $0.id },
                    isActive: true,
                    schoolId: user.schoolId,
                    grade: user.grade,
                    type: "Poll",
                    category: question.category,
                    usersWhoVoted: [] // Initialize with empty array
                )
                selectedPoll = poll

                newPolls.append(poll)
                newOptions.append(contentsOf: options)
            }
        }

        // Prepare data for batch savex
        var batchDocuments: [(collection: String, data: [String: Any])] = []

        for poll in newPolls {
            if let pollData = poll.encodeToDictionary() {
                batchDocuments.append((collection: "polls", data: pollData))
            }
        }

        for option in newOptions {
            if let optionData = option.encodeToDictionary() {
                batchDocuments.append((collection: "pollOptions", data: optionData))
            }
        }

        do {
            // Perform batch save
            try await FirebaseService.shared.batchSave(documents: batchDocuments)

            // Update local state
            self.allPolls.append(contentsOf: newPolls)
            self.pollSet = self.allPolls.filter { !$0.usersWhoVoted.contains(user.id) }
            self.pollSet.sort { $0.createdAt > $1.createdAt }
            if let first = self.pollSet.first {
                self.selectedPoll = first
                await self.getPollOptions()
            }
        } catch {
            print("Error creating polls: \(error.localizedDescription)")
        }
    }

    func createOptions(users: [User]) -> [PollOption] {
        // if user has made in app purchase they have highest priority
        // number of votedPolls they have should be close second
        // number of friends they have
        // random

        let maxVotedPolls = users.map { $0.votedPolls.count }.max() ?? 1
        let maxFriends = users.map { $0.friends.count }.max() ?? 1

        // Calculate a score for each user
        let scoredUsers = users.map { user -> (User, Double) in
            let votedPollsScore = Double(user.votedPolls.count) / Double(maxVotedPolls)
            let friendsScore = Double(user.friends.count) / Double(maxFriends)
            
            // Calculate the final score with some randomness
            let randomFactor = Double.random(in: 0...0.2)
            let score = (votedPollsScore * 0.6) + (friendsScore * 0.3) + randomFactor
            
            return (user, score)
        }

        // Sort users by their scores in descending order
        let sortedUsers = scoredUsers.sorted { $0.1 > $1.1 }

        // Select top 4 users, but with a chance to include lower-ranked users
        var selectedUsers: [User] = []
        var remainingUsers = sortedUsers

        while selectedUsers.count < 12 && !remainingUsers.isEmpty {
            let randomThreshold = Double.random(in: 0...1)
            let index: Int
            
            if randomThreshold < 0.7 {
                // 70% chance to select from top half
                index = Int.random(in: 0..<min(remainingUsers.count, max(remainingUsers.count / 2, 1)))
            } else {
                // 30% chance to select from anywhere
                index = Int.random(in: 0..<remainingUsers.count)
            }
            
            selectedUsers.append(remainingUsers[index].0)
            remainingUsers.remove(at: index)
        }

        // Convert selected users to PollOptions, ensuring we have exactly 4 options
        let options = selectedUsers.prefix(12).map { user in
            PollOption(
                id: UUID().uuidString,
                type: "Poll",
                pollId: selectedPoll.id,
                option: "\(user.firstName) \(user.lastName)",
                votes: [:],
                gradeLevel: user.grade
            )
        }


        return options
    }

    func getSelectedPollResults() {
        // Implement logic to get poll results
    }
    
    func getPollOptions() async {
        do {
            let options: [PollOption] = try await FirebaseService.shared.fetchDocuments(
                collection: "pollOptions",
                whereField: "pollId",
                isEqualTo: selectedPoll.id,
                limit: 12
            )
            self.currentOptions = options.shuffled()
            self.currentFourOptions = Array(self.currentOptions.prefix(4))
            self.currentOptionIndex = 4
            updateQuestionEmoji()
            resetPollState() // Reset the state for the new poll
        } catch {
            print("Error getting poll options: \(error.localizedDescription)")
        }
    }
    
    func shuffleOptions() {
        let totalOptions = currentOptions.count
        
        if currentOptionIndex >= totalOptions {
            // If we've shown all options, reshuffle and start over
            currentOptions.shuffle()
            currentOptionIndex = 0
        }
        
        let endIndex = min(currentOptionIndex + 4, totalOptions)
        currentFourOptions = Array(currentOptions[currentOptionIndex..<endIndex])
        
        // If we don't have 4 options, wrap around to the beginning
        if currentFourOptions.count < 12 {
            let remainingCount = 4 - currentFourOptions.count
            currentFourOptions += Array(currentOptions[0..<remainingCount])
        }
        
        currentOptionIndex = (currentOptionIndex + 4) % totalOptions
        
        updateQuestionEmoji()
    }

     func updateQuestionEmoji() {
        if let matchingQuestion = Question.allQuestions.first(where: { $0.question == selectedPoll.title }) {
            self.questionEmoji = matchingQuestion.emoji
        } else {
            self.questionEmoji = "❓" // Default emoji if no match found
        }
    }

    func resetPollState() {
        showProgress = false
        animateProgress = false
        animateAllOptions = false
    }

    // Other methods remain unchanged
}
