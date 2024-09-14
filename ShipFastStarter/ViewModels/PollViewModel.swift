//
//  PollViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import Foundation
import FirebaseFirestore
import SwiftUI

@MainActor
class PollViewModel: ObservableObject {
    @Published var pollSet: [Poll] = [Poll.exPoll]
    @Published var allPolls: [Poll] = []
    @Published var selectedPoll: Poll = Poll.exPoll
    @Published var currentFourOptions: [PollOption] = [PollOption.exPollOption]
    @Published var showProgress: Bool = false
    @Published var animateProgress: Bool = false
    @Published var animateAllOptions: Bool = false
    @Published var questionEmoji: String = ""
    @Published var completedPoll: Bool = true
    @Published var totalVotes: Int = 0
    @Published var cooldownEndTime: Date?
    @Published var timeRemaining: TimeInterval = 0
    @Published var randomizedPeople: [(String, String)] = []
    @Published var currentPollOptionIndex: Int = 0
    @Published var currentPollIndex: Int = 0
    
    private var timer: Timer?

    init() {
        updateQuestionEmoji()
        randomizePeople()
    }
    
    func randomizePeople() {
       let randomNumber = Int.random(in: 2...4)
 
       
       let randomPerson = 0
        
        for _ in 0..<randomNumber {
            var randGender = Int.random(in: 0...1)
            var color = Int.random(in: 0...7)
            print(randGender, color, "what is going on?")
            randomizedPeople.append((randGender == 0 ? "boy" : "girl", Constants.colors[color]))
         }
    }
    
    func updateRandomPeople() {
        
    }

    func fetchPolls(for user: User) async {
        if UserDefaults.standard.integer(forKey: Constants.currentIndex) != 0 {
            currentPollIndex = UserDefaults.standard.integer(forKey: Constants.currentIndex)
            if pollSet.isEmpty {
                if let pollIds = UserDefaults.standard.array(forKey: Constants.pollIds) {
                    for poll in pollIds {
                        do {
                            let polls: [Poll] = try await FirebaseService.shared.fetchDocuments(
                                collection: "polls",
                                whereField: "id",
                                isEqualTo: poll
                            )
                            if let first = polls.first {
                                pollSet.append(first)
                            }
                        } catch {
                            print(error.localizedDescription, "Error fetching polls")
                        }
                       
                    }
                    self.pollSet.sort { $0.createdAt > $1.createdAt }
                    // Limit pollSet to the first 8 polls
                    self.pollSet = Array(self.pollSet.prefix(8))
                    // create array of poll ids
                    let pollIds = pollSet.map { $0.id }
                    UserDefaults.standard.setValue(pollIds, forKey: Constants.pollIds)
                    self.selectedPoll = pollSet[currentPollIndex]
                    self.getPollOptions(excludingUserId: user.id)
                    updateQuestionEmoji()
                    
                }
            }
            return
        }
        
        do {
            let polls: [Poll] = try await FirebaseService.shared.fetchDocuments(
                collection: "polls",
                whereField: "schoolId",
                isEqualTo: user.schoolId
            )
            
            self.allPolls = polls
            self.pollSet = polls.filter { !$0.usersWhoVoted.contains(user.id) }
            self.pollSet.sort { $0.createdAt > $1.createdAt }
            
            if pollSet.count < 8 {
                await createPoll(user: user)
            }
            // Limit pollSet to the first 8 polls
            self.pollSet = Array(self.pollSet.prefix(8))
            // create array of poll ids
            let pollIds = pollSet.map { $0.id }
            
            UserDefaults.standard.setValue(pollIds, forKey: Constants.pollIds)

            if let first = self.pollSet.first {
                self.selectedPoll = first
                self.getPollOptions(excludingUserId: user.id)
                updateQuestionEmoji()
            }
          
        } catch {
            print("Error fetching polls: \(error.localizedDescription)")
        }
    }

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
            if var voteObj = updatedPoll.pollOptions[optionIndex].votes?[user.id] {
                var currentVotes = Int(voteObj["numVotes"] ?? "1") ?? 1
                currentVotes += 1
                updatedPoll.pollOptions[optionIndex].votes?[user.id] = [
                    "date": dateString,
                    "numVotes": String(currentVotes),
                    "viewedNotification": "false"
                ]
            } else {
                updatedPoll.pollOptions[optionIndex].votes?[user.id] = [
                    "date": dateString,
                    "numVotes": "1",
                    "viewedNotification": "false"
                ]
            }
            
          
            
            updatedPoll.usersWhoVoted.append(user.id)
            
            selectedPoll = updatedPoll
            if let index = pollSet.firstIndex(where: { $0.id == updatedPoll.id }) {
                pollSet[index] = updatedPoll
            }
            
            updateTotalVotes()
            showProgress = true
            animateProgress = true
            animateAllOptions = true
            
            // Force UI update
            objectWillChange.send()
            
            // Perform Firebase updates
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
                self.getPollOptions(excludingUserId: user.id)
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

    func getPollOptions(excludingUserId userId: String) {
        guard !selectedPoll.pollOptions.isEmpty else {
            print("Selected poll has no options")
            return
        }
        
        // Filter out options with the user's ID
        let availableOptions = selectedPoll.pollOptions.filter { $0.userId != userId }
        
        guard !availableOptions.isEmpty else {
            print("No available options after filtering")
            return
        }
        
        // Take up to 4 options from the available options
        currentFourOptions = Array(availableOptions.prefix(4))
        currentPollOptionIndex = min(4, availableOptions.count)
        
        updateQuestionEmoji()
        updateTotalVotes()
        resetPollState()
        
        // Print debug information
        print("getPollOptions called")
        print("Selected poll has \(selectedPoll.pollOptions.count) total options")
        print("Available options after filtering: \(availableOptions.count)")
        print("Current four options: \(currentFourOptions.map { $0.option })")
    }

    func shuffleOptions(excludingUserId: String) {
        let totalOptions = selectedPoll.pollOptions.count
        var availableOptions = selectedPoll.pollOptions.filter { $0.userId != excludingUserId }

        if currentPollOptionIndex >= totalOptions {
            availableOptions.shuffle()
            currentPollOptionIndex = 0
        }
        
        let endIndex = min(currentPollOptionIndex + 4, availableOptions.count)
        currentFourOptions = Array(availableOptions[currentPollOptionIndex..<endIndex])
        
        if currentFourOptions.count < 4 {
            let remainingCount = 4 - currentFourOptions.count
            currentFourOptions += Array(availableOptions[0..<min(remainingCount, availableOptions.count)])
        }
        
        currentPollOptionIndex = (currentPollOptionIndex + 4) % max(1, availableOptions.count)
        
        updateQuestionEmoji()
        
        // Print debug information
        print("shuffleOptions called")
        print("Current four options after shuffle: \(currentFourOptions.map { $0.option })")
    }
    
    func startCooldownTimer() {
        guard timer == nil else { return }
        updateTimeRemaining()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateTimeRemaining()
            }
        }
    }
    
    func stopCooldownTimer() {
        timer?.invalidate()
        timer = nil
    }

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

    func updateQuestionEmoji() {
        if let matchingQuestion = Question.allQuestions.first(where: { $0.question == selectedPoll.title }) {
            self.questionEmoji = matchingQuestion.emoji
        } else {
            self.questionEmoji = "❓"
        }
    }

    func resetPollState() {
        showProgress = false
        animateProgress = false
        animateAllOptions = false
    }

    func updateTotalVotes() {
        totalVotes = selectedPoll.pollOptions.reduce(0) { total, option in
            total + (option.votes?.values.reduce(0) { $0 + (Int($1["numVotes"] ?? "0") ?? 0) } ?? 0)
        }
        print("Updated total votes: \(totalVotes)")
        objectWillChange.send()
    }

    func finishPoll(user: User) {
        let cooldownDuration: TimeInterval = 12 * 60 * 60
        cooldownEndTime = Date().addingTimeInterval(cooldownDuration)
        startCooldownTimer()
        
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

    func checkCooldown(user: User) {
        if let lastPollFinished = user.lastPollFinished {
            let cooldownDuration: TimeInterval = 12 * 60 * 60
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

    func resetCooldown(user: User) {
        let twelveHoursAgo = Date().addingTimeInterval(-12 * 60 * 60)
        cooldownEndTime = nil
        timeRemaining = 0
        stopCooldownTimer()
        completedPoll = false
        objectWillChange.send()

        Task {
            do {
                var updatedUser = user
                updatedUser.lastPollFinished = twelveHoursAgo
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

    func hasNewNotifications(for user: User) -> Bool {
        return selectedPoll.pollOptions.contains { option in
            option.votes?[user.id]?["viewedNotification"] == "false"
        }
    }

    func markNotificationsAsViewed(for user: User) async {
        for i in 0..<selectedPoll.pollOptions.count {
            if var votes = selectedPoll.pollOptions[i].votes?[user.id],
               votes["viewedNotification"] == "false" {
                votes["viewedNotification"] = "true"
                selectedPoll.pollOptions[i].votes?[user.id] = votes
                
                do {
                    try await FirebaseService.shared.updateDocument(
                        collection: "pollOptions",
                        object: selectedPoll.pollOptions[i]
                    )
                } catch {
                    print("Error updating poll option: \(error.localizedDescription)")
                }
            }
        }
        objectWillChange.send()
    }

    deinit {
        // We can't call stopCooldownTimer() directly here, so we'll use a workaround
        Task { @MainActor in
            self.stopCooldownTimer()
        }
    }
}
