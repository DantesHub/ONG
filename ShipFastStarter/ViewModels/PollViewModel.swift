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
    @Published var allPolls: [Poll] = []
    @Published var pollSet: [Poll] = []
    @Published var selectedPoll: Poll = Poll.exPoll
    @Published var currentFourOptions: [PollOption] = []
    @Published var allOptions: [PollOption] = []
    @Published var currentTwelveOptions: [PollOption] = []
    @Published var showProgress: Bool = false
    @Published var animateProgress: Bool = false
    @Published var animateAllOptions: Bool = false
    @Published var isNewPollReady: Bool = true
    @Published var questionEmoji: String = ""
    @Published var completedPoll: Bool = false
    @Published var cooldownEndTime: Date?
    @Published var timeRemaining: TimeInterval = 0
    @Published var randomizedPeople: [(String, String)] = []
    @Published var currentPollOptionIndex: Int = 0
    @Published var currentPollIndex: Int = 0
    @Published var friends: [User] = []
    @Published var entireSchool: [User] = []
    
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
            randomizedPeople.append((randGender == 0 ? "boy" : "girl", Constants.colors[color]))
        }
    }
    
    func fetchPolls(for user: User) async {
        do {
            print("Fetching polls for user \(user.id)")
            let votes: [Vote] = try await FirebaseService.shared.fetchDocuments(
                collection: FirestoreCollections.votes,
                whereField: "voterId",
                isEqualTo: user.id
            )
            let votedPollIds = votes.map { $0.pollId }
            
            let allActivePolls: [Poll] = try await FirebaseService.shared.fetchDocumentsWithFilters(
                collection: FirestoreCollections.polls,
                whereField: "schoolId",
                isEqualTo: user.schoolId,
                additionalFilters: [
                    ("status", "isEqualTo", "active")
                ],
                orderBy: ("createdAt", true)
            )
            
            // Then, filter out the polls the user has already voted on
            let filteredPolls = allActivePolls.filter { poll in
                !votedPollIds.contains(poll.id)
            }
            
            // Finally, take the first 8 polls
            self.allPolls = allActivePolls
            self.pollSet = Array(filteredPolls.prefix(8))
            
            // setup allOptions here, which is all the users in the school
            let allUsers: [User] = try await FirebaseService.shared.fetchDocuments(
                collection: FirestoreCollections.users,
                whereField: "schoolId",
                isEqualTo: user.schoolId
            )
            self.allOptions = allUsers
                .filter { $0.id != user.id }
                .map {
                    PollOption(
                        id: $0.id,
                        type: "Poll",
                        option: "\($0.firstName) \($0.lastName)",
                        userId: $0.id,
                        gradeLevel: $0.grade
                    )
                }
            
            let pollIds = pollSet.map { $0.id }
            UserDefaults.standard.setValue(pollIds, forKey: Constants.pollIds)
            
            if let first = self.pollSet.first {
                self.selectedPoll = first
            }
            
            if UserDefaults.standard.integer(forKey: Constants.currentIndex) != 0  {
                currentPollIndex = UserDefaults.standard.integer(forKey: Constants.currentIndex)
                self.selectedPoll = pollSet[currentPollIndex]
            }
            
        } catch {
            print("Error fetching polls: \(error.localizedDescription)")
        }
    }
    
    func answerPoll(user: User, option: PollOption, optionUser: User, totalVotes: Int) async {
        if let optionIndex = currentFourOptions.firstIndex(where: { $0.id == option.id }) {
            
            let currentDate = Date()
            let dateString = ISO8601DateFormatter().string(from: currentDate)

            let vote = Vote(
                id: UUID().uuidString,
                voterId: user.id,
                votedForId: optionUser.id,
                schoolId: user.schoolId,
                votedForOptionIndex: optionIndex,
                amount: totalVotes,
                pollId: selectedPoll.id,
                createdAt: currentDate,
                viewedNotification: false,
                pollOptions: currentFourOptions.map { $0.option },
                question: selectedPoll.title
            )

            if let index = self.pollSet.firstIndex(where: { $0.id == self.selectedPoll.id }) {
                self.pollSet[index].voteSummary[optionUser.id, default: 0] += totalVotes
                self.selectedPoll = self.pollSet[index]
            } else {
                print("Error: Selected poll not found in pollSet")
            }

            
            showProgress = true
            animateProgress = true
            animateAllOptions = true
            
            // Force UI update
            objectWillChange.send()
            
            // Perform Firebase updates
            do {
                FirebaseService.shared.addDocument(
                    vote,
                    collection: FirestoreCollections.votes,
                    completion: {_ in }
                )

                try await FirebaseService.shared.updateFields(
                    collection: FirestoreCollections.polls,
                    documentId: self.selectedPoll.id,
                    fields: ["voteSummary": self.selectedPoll.voteSummary]
                )

                var updatedOptionUser = optionUser
                updatedOptionUser.aura += totalVotes

                try await FirebaseService.shared.updateDocument(
                    collection: FirestoreCollections.users,
                    object: updatedOptionUser
                )
            } catch {
                print("Error answering poll: \(error.localizedDescription)")
            }
        } else {
            print("Failed to find matching poll or option")
        }
    }
    
    func initPolls(for user: User) async {
        // if there are no polls in the db, create them
        do {
            let polls: [Poll] = try await FirebaseService.shared.fetchDocuments(collection: FirestoreCollections.polls, whereField: "schoolId", isEqualTo: user.schoolId)
            
            if polls.isEmpty {
                print("No polls yet for school: \(user.schoolId), initializing.")
                
                var pollQuestions = Question.bsQuestions
                
                var newPolls: [Poll] = []
                for question in pollQuestions {
                    let poll = Poll(
                        id: UUID().uuidString,
                        title: question.question,
                        createdAt: Date(),
                        status: "active",
                        schoolId: user.schoolId,
                        grade: user.grade,
                        type: "Poll",
                        category: question.category,
                        voteSummary: [:]
                    )
                    newPolls.append(poll)
                }
                
                var batchDocuments: [(collection: String, data: [String: Any])] = []
                
                for poll in newPolls {
                    if let pollData = poll.encodeToDictionary() {
                        batchDocuments.append((collection: FirestoreCollections.polls, data: pollData))
                    }
                }

                do {
                    try await FirebaseService.shared.batchSave(documents: batchDocuments)
                } catch {
                    print("Error creating polls: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error fetching polls: \(error.localizedDescription)")
        }
        
    }
    
    func createNewOptions(user: User, friends: [User]) {
        let friendOptions = friends.filter { friend in
            let friendNotAnOption = allOptions.contains { $0.userId != friend.id }
            return friendNotAnOption
        }
        
        
        if allOptions.contains(where: { option in
            option.userId != user.id
        }) {
            // add the user as an option
            var userOption = PollOption(
                id: UUID().uuidString,
                type: "Poll",
                option: "\(user.firstName) \(user.lastName)",
                userId: user.id,
                gradeLevel: user.grade
            )
            userOption.priorityScore = -3
            allOptions.append(userOption)
        }
        
        for friend in friendOptions {
            var newOption = PollOption(
                id: UUID().uuidString,
                type: "Poll",
                option: "\(friend.firstName) \(friend.lastName)",
                userId: friend.id,
                gradeLevel: friend.grade
            )
            
            newOption.priorityScore = calculatePriorityScore(for: newOption, user: friend)
            allOptions.append(newOption)
        }
        
        // start creating new ones
        //MARK: - experiemnt do we put in the top 3 voters or do we put randoms from the grade that havent had the chance ?
        // priority #3 getting users from the grade who don't have much aura
        var sortedUsersInGrade = entireSchool.filter { $0.grade == user.grade }.sorted { (usr1, usr2) -> Bool in
            let aura1 = friends.first(where: { $0.id == usr1.id })?.aura ?? 0
            let aura2 = friends.first(where: { $0.id == usr2.id })?.aura ?? 0
            return aura1 < aura2
        }
        
        // means we're creating a new poll
        if allOptions.count < 13 {
            sortedUsersInGrade.shuffle()
        }
        
        
        // Filter out users who are already in the friends array
        let filteredUsersInGrade = sortedUsersInGrade.filter { user in
            !friends.contains { $0.id == user.id }
        }
        
        // this should push up users who arent getting votes
        for (idx, userInGrade) in filteredUsersInGrade.enumerated() {
            if !allOptions.contains(where: { option in
                option.userId == userInGrade.id
            }) {
                if allOptions.count == 11 {
                    break
                }
                
                var newOption = PollOption(
                    id: UUID().uuidString,
                    type: "Poll",
                    option: "\(userInGrade.firstName) \(userInGrade.lastName)",
                    userId: userInGrade.id,
                    gradeLevel: userInGrade.grade
                )
                
                newOption.priorityScore = calculatePriorityScore(for: newOption, user: userInGrade)
                
                newOption.priorityScore += 3
                allOptions.append(newOption)
            }
        }
        
        // finally if allOptions is still not > 12 we will add in rest of school here
        // Filter entireSchool to exclude users already in allOptions
        var remainingUsers = entireSchool.filter { schoolUser in
            !allOptions.contains { $0.userId == schoolUser.id }
        }
        
        remainingUsers.shuffle()
        
        // Add remaining users to allOptions if needed
        for remainUser in remainingUsers {
            if allOptions.count >= 13 {
                break
            }
            
            var newOption = PollOption(
                id: UUID().uuidString,
                type: "Poll",
                option: "\(remainUser.firstName) \(remainUser.lastName)",
                userId: remainUser.id,
                gradeLevel: remainUser.grade
            )
            
            newOption.priorityScore = calculatePriorityScore(for: newOption, user: remainUser)
            
            
            allOptions.append(newOption)
        }
        
    }
    
    func getPollOptions(excludingUserId user: User) {
        var updatedOptions: [PollOption] = []
        var totalFriendOptions = 0
        var totalSameGradeOptions = 0
        
        for option in allOptions {
            var updatedOption = option
            updatedOption.priorityScore = calculatePriorityScore(for: option, user: user)
            
            if friends.contains(where: { $0.id == option.userId }) {
                totalFriendOptions += 1
            }
            
            if user.grade == option.gradeLevel {
                totalSameGradeOptions += 1
            }
            
            updatedOptions.append(updatedOption)
        }
        
        // Sort priority options by score
        updatedOptions.sort { $0.priorityScore > $1.priorityScore }
        allOptions = updatedOptions
        
        // Remove duplicate options with the same userId
        var seenUserIds = Set<String>()
        allOptions = allOptions.filter { option in
            if seenUserIds.contains(option.userId) {
                return false
            }
            seenUserIds.insert(option.userId)
            return true
        }
        
        print(totalFriendOptions, totalSameGradeOptions,  "totalFriend & Grade options")
        // totalPriorityScore determines relevancy for the polloptions
        // increase the relevancy of the options
        if (user.friends.count > 7 && totalFriendOptions <= 7) || totalSameGradeOptions < 8 || allOptions.count < 12  { // create new friend options
            createNewOptions(user: user, friends: friends)
            // Sort priority options by score
        }
        
        allOptions.sort { $0.priorityScore > $1.priorityScore }
        
        seenUserIds = Set<String>()
        allOptions = allOptions.filter { option in
            if seenUserIds.contains(option.userId) {
                return false
            }
            seenUserIds.insert(option.userId)
            return true
        }
        
        
        
        allOptions = allOptions.filter { option in
            option.userId != user.id
        }
        
        currentTwelveOptions = Array(allOptions.prefix(12)).shuffled()
        // Take up to 4 options from the available options
        currentFourOptions = Array(currentTwelveOptions.prefix(4))
        currentPollOptionIndex = min(4, allOptions.count)
        
        updateQuestionEmoji()
        resetPollState()
        
        // Print debug information
        print("getPollOptions called")
        print("Available options after filtering: \(updatedOptions.count)")
        print("Current four options: \(currentFourOptions.map { $0.option })")
        
    }
    
    func shuffleOptions(excludingUserId: String) {
        let totalOptions = allOptions.count
        var availableOptions = currentTwelveOptions.filter { $0.userId != excludingUserId }
        
        if currentPollOptionIndex >= totalOptions {
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
    
    func updateQuestionEmoji() {
        if let matchingQuestion = Question.bsQuestions.first(where: { $0.question == selectedPoll.title }) {
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
    
    
    func finishPoll(user: User) {
        self.isNewPollReady = false
        let cooldownDuration: TimeInterval = 6 * 60 * 60
        cooldownEndTime = Date().addingTimeInterval(cooldownDuration)
        startCooldownTimer()
        
        // Schedule notification for 6 hours from now
        let notificationDate = Date().addingTimeInterval(cooldownDuration)
        NotificationManager.scheduleNotification(
            title: "New polls are open!",
            body: "stack ur bread, and get ur aura up",
            date: notificationDate
        )
        
        Task {
            do {
                try await FirebaseService.shared.updateDocument(
                    collection: FirestoreCollections.users,
                    object: user
                )
            } catch {
                print("Error updating user's last poll finished time: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - COOL DOWN LOGIC
    func timeRemainingString() -> String {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
    
    func checkCooldown(user: User) {
        if let lastPollFinished = user.lastPollFinished {
            let cooldownDuration: TimeInterval = 6 * 60 * 60
            let cooldownEndTime = lastPollFinished.addingTimeInterval(cooldownDuration)
            if Date() < cooldownEndTime {
                self.cooldownEndTime = cooldownEndTime
                self.isNewPollReady = false
                startCooldownTimer()
            } else {
                self.cooldownEndTime = nil
                self.isNewPollReady = true
                stopCooldownTimer()
            }
        } else {
            self.cooldownEndTime = nil
            self.isNewPollReady = true
            stopCooldownTimer()
        }
    }
    
    func resetCooldown(user: User) {
        let twelveHoursAgo = Date().addingTimeInterval(-6 * 60 * 60)
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
                    collection: FirestoreCollections.users,
                    object: updatedUser
                )
                print("User updated in Firebase after cooldown reset")
            } catch {
                print("Error updating user in Firebase after cooldown reset: \(error.localizedDescription)")
            }
        }
    }
    deinit {
        // We can't call stopCooldownTimer() directly here, so we'll use a workaround
        Task { @MainActor in
            self.stopCooldownTimer()
        }
    }
    
    func resetState() {
        // Reset all relevant properties
        self.completedPoll = false
        self.cooldownEndTime = nil
        // Reset any other properties as needed
    }
    
    
    func calculateDaysSinceLastPoll(for user: User) -> Int {
        let calendar = Calendar.current
        let now = Date()
        if let lastPollFinished = user.lastPollFinished {
            return calendar.dateComponents([.day], from: lastPollFinished, to: now).day ?? 0
        } else {
            return 7
        }
    }
    
    func calculatePriorityScore(for option: PollOption, user: User) -> Int {
        var score = 0
        let daysSinceLastPoll = calculateDaysSinceLastPoll(for: user)
        let voteCount = selectedPoll.voteSummary[option.userId] ?? 0
        let hasVotes = voteCount > 0
        let isFriend = friends.contains { $0.id == option.userId }
        let sameGrade = user.grade == option.gradeLevel
        
        if hasVotes && isFriend {
            score += 7
        } else if isFriend {
            score += 5
        } else if hasVotes {
            score += 1
        }
        
        if sameGrade {
            score += 2
        }
        
        if daysSinceLastPoll > 5 {
            score -= 5
        } else if daysSinceLastPoll > 3 {
            score -= 3
        }
        
        return score
    }
}
