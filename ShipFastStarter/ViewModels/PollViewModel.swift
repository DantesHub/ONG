//
//  PollViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import Foundation
import FirebaseFirestore

class PollViewModel: ObservableObject {
    @Published var pollSet: [Poll] = [Poll.exPoll]
    @Published var allPolls: [Poll] = [Poll.exPoll]
    @Published var selectedPoll: Poll = Poll.exPoll
    @Published var currentFourOptions: [PollOption] = []
    @Published var showProgress: Bool = false
    @Published var animateProgress: Bool = false
    @Published var animateAllOptions: Bool = false
    @Published var questionEmoji: String = ""
    @Published var completedPoll: Bool = true
    private var currentOptionIndex: Int = 0
    @Published var totalVotes: Int = 0
    @Published var cooldownEndTime: Date?
    @Published var timeRemaining: TimeInterval = 0
    private var timer: Timer?

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
            
            // Fetch poll options for each poll
            for var poll in polls {
                let options: [PollOption] = try await FirebaseService.shared.fetchDocuments(
                    collection: "pollOptions",
                    whereField: "pollId",
                    isEqualTo: poll.id
                )
                poll.pollOptions = options
            }
            
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
    
    @MainActor
    func answerPoll(user: User, option: PollOption) async {
        print("Answering poll for option: \(option.option)")
        if var updatedPoll = pollSet.first(where: { $0.id == selectedPoll.id }),
           let optionIndex = updatedPoll.pollOptions.firstIndex(where: { $0.id == option.id }) {
            
            let currentDate = Date()
            let dateString = ISO8601DateFormatter().string(from: currentDate)
            
            // Update votes with the new structure
            if updatedPoll.pollOptions[optionIndex].votes == nil {
                updatedPoll.pollOptions[optionIndex].votes = [:]
            }
            updatedPoll.pollOptions[optionIndex].votes?[user.id] = [
                "date": dateString,
                "numVotes": "1",
                "viewedNotification": "false"
            ]
            
            updatedPoll.usersWhoVoted.append(user.id)
            
            selectedPoll = updatedPoll
            if let index = pollSet.firstIndex(where: { $0.id == updatedPoll.id }) {
                pollSet[index] = updatedPoll
            }
            
            updateTotalVotes()
            showProgress = true
            animateProgress = true
            animateAllOptions = true
            
            print("Updated poll: \(updatedPoll)")
            print("Total votes: \(totalVotes)")
            print("Show progress: \(showProgress)")
            print("Animate progress: \(animateProgress)")
            
            // Force UI update
            objectWillChange.send()
            
            // Perform Firebase updates
            Task {
                do {
                    try await FirebaseService.shared.updateDocument(
                        collection: "polls",
                        object: updatedPoll
                    )
                    
                    var updatedUser = user
                    updatedUser.votedPolls.append(updatedPoll.id)
                    try await FirebaseService.shared.updateDocument(
                        collection: "users",
                        object: updatedUser
                    )
                    print("Firebase update completed")
                } catch {
                    print("Error answering poll: \(error.localizedDescription)")
                }
            }
        } else {
            print("Failed to find matching poll or option")
        }
    }

    func createPoll(user: User) async {
        var potentialQuestions = Question.allQuestions.filter { question in
            !allPolls.contains { $0.title == question.question }
        }

        var newPolls: [Poll] = []
        while pollSet.count < 8 && !potentialQuestions.isEmpty {
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
                    pollOptions: options,
                    isActive: true,
                    schoolId: user.schoolId,
                    grade: user.grade,
                    type: "Poll",
                    category: question.category,
                    usersWhoVoted: [] // Initialize with empty array
                )
                selectedPoll = poll

                pollSet.append(poll)
                newPolls.append(poll)
            }
        }

        // Prepare data for batch save
        var batchDocuments: [(collection: String, data: [String: Any])] = []

        for poll in newPolls {
            if let pollData = poll.encodeToDictionary() {
                batchDocuments.append((collection: "polls", data: pollData))
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

        // Convert selected users to PollOptions, ensuring we have exactly 12 options
        let options = selectedUsers.prefix(12).map { user in
            PollOption(
                id: UUID().uuidString,
                type: "Poll",
                option: "\(user.firstName) \(user.lastName)",
                userId: user.id,
                votes: [:], // Initialize with empty dictionary
                gradeLevel: user.grade
            )
        }

        return options
    }

    func getSelectedPollResults() {
        // Implement logic to get poll results
    }
    
    func getPollOptions() async {
        currentFourOptions = Array(selectedPoll.pollOptions.prefix(4))
        currentOptionIndex = 4
        updateQuestionEmoji()
        await updateTotalVotes()  // Update total votes when getting new options
        resetPollState()
    }
    
    func shuffleOptions() {
        let totalOptions = selectedPoll.pollOptions.count
        
        if currentOptionIndex >= totalOptions {
            // If we've shown all options, reshuffle and start over
            selectedPoll.pollOptions.shuffle()
            currentOptionIndex = 0
        }
        
        let endIndex = min(currentOptionIndex + 4, totalOptions)
        currentFourOptions = Array(selectedPoll.pollOptions[currentOptionIndex..<endIndex])
        
        // If we don't have 4 options, wrap around to the beginning
        if currentFourOptions.count < 4 {
            let remainingCount = 4 - currentFourOptions.count
            currentFourOptions += Array(selectedPoll.pollOptions[0..<remainingCount])
        }
        
        currentOptionIndex = (currentOptionIndex + 4) % totalOptions
        
        updateQuestionEmoji()
    }

    @MainActor
    func startCooldownTimer() {
        stopCooldownTimer() // Ensure any existing timer is stopped
        updateTimeRemaining()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateTimeRemaining()
            }
        }
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
    
    @MainActor
    func updateTotalVotes() {
        totalVotes = selectedPoll.pollOptions.reduce(0) { total, option in
            total + (option.votes?.values.reduce(0) { $0 + (Int($1["numVotes"] ?? "0") ?? 0) } ?? 0)
        }
        print("Updated total votes: \(totalVotes)")
//        print("Poll options votes: \(selectedPoll.pollOptions.map { option in
//            let votes = option.votes?.values.reduce(0) { sum, voteInfo in
//                sum + (Int(voteInfo["numVotes"] ?? "0") ?? 0)
//            } ?? 0
//            return (option.option, votes)
//        })")
        objectWillChange.send()  // Force update
    }

    // Update this method if you need to calculate progress for each option
    private func calculateProgress(for option: PollOption) -> Double {
        guard totalVotes > 0 else { return 0 }
        let optionVotes = option.votes?.values.reduce(0) { $0 + (Int($1["numVotes"] ?? "0") ?? 0) } ?? 0
        return Double(optionVotes) / Double(totalVotes)
    }

    @MainActor
    func finishPoll(user: User) {
        let cooldownDuration: TimeInterval = 12 * 60 * 60 // 12 hours in seconds
        cooldownEndTime = Date().addingTimeInterval(cooldownDuration)
        startCooldownTimer()
        
        // Update user's last poll finished time in Firebase
        Task {
            do {
                var updatedUser = user
                updatedUser.lastPollFinished = Date()
                try await FirebaseService.shared.updateDocument(
                    collection: "users",
                    object: updatedUser
                )
            } catch {
                print("Error updating user's last poll finished time: \(error.localizedDescription)")
            }
        }
    }
    @MainActor
    func checkCooldown(user: User) {
        if let lastPollFinished = user.lastPollFinished {
            let cooldownDuration: TimeInterval = 12 * 60 * 60 // 12 hours in seconds
            let cooldownEndTime = lastPollFinished.addingTimeInterval(cooldownDuration)
            if Date() < cooldownEndTime {
                self.cooldownEndTime = cooldownEndTime
                startCooldownTimer()
            } else {
                self.cooldownEndTime = nil
                stopCooldownTimer()
            }
        } else {
            self.cooldownEndTime = nil
            stopCooldownTimer()
        }
    }

     func stopCooldownTimer() {
        timer?.invalidate()
        timer = nil
    }

    @MainActor
    private func updateTimeRemaining() {
        guard let cooldownEndTime = cooldownEndTime else {
            timeRemaining = 0
            return
        }
        
        timeRemaining = max(0, cooldownEndTime.timeIntervalSinceNow)
        if timeRemaining == 0 {
            stopCooldownTimer()
            self.cooldownEndTime = nil
        }
    }

    func timeRemainingString() -> String {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func resetCooldown(user: User) {
        let twelveHoursAgo = Date().addingTimeInterval(-12 * 60 * 60) // 12 hours before now
        cooldownEndTime = nil
        timeRemaining = 0
        stopCooldownTimer()
        completedPoll = false
        objectWillChange.send()

        // Update user in Firebase
        Task {
            do {
                var updatedUser = user
                updatedUser.lastPollFinished = twelveHoursAgo // Set to 12 hours ago instead of nil
                try await FirebaseService.shared.updateDocument(
                    collection: "users",
                    object: updatedUser
                )
                print("User updated in Firebase after cooldown reset")
            } catch {
                print("Error updating user in Firebase after cooldown reset: \(error.localizedDescription)")
            }
        }
    }

    // New function to check for new notifications
    func hasNewNotifications(for user: User) -> Bool {
        return selectedPoll.pollOptions.contains { option in
            option.votes?[user.id]?["viewedNotification"] == "false"
        }
    }

    // New function to mark notifications as viewed
    func markNotificationsAsViewed(for user: User) async {
        for i in 0..<selectedPoll.pollOptions.count {
            if var votes = selectedPoll.pollOptions[i].votes?[user.id],
               votes["viewedNotification"] == "false" {
                votes["viewedNotification"] = "true"
                selectedPoll.pollOptions[i].votes?[user.id] = votes
                
                // Update in Firebase
                try? await FirebaseService.shared.updateDocument(
                    collection: "pollOptions",
                    object: selectedPoll.pollOptions[i]
                )
            }
        }
        objectWillChange.send()
    }

    deinit {
        stopCooldownTimer()
    }
}
