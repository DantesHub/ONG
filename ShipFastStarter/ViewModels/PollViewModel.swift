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
    @Published var pollSet: [Poll] = []
    @Published var allPolls: [Poll] = []
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
    @Published var totalVotes: Int = 0
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
        print(" *******  *******  ******* fetching or initializing polls  ******* ******* *******")
        if UserDefaults.standard.integer(forKey: Constants.currentIndex) != 0  {
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
                    
                    if pollSet.isEmpty {
                        Task {
                            UserDefaults.standard.setValue(0, forKey: Constants.currentIndex)
                            currentPollIndex = 0
                            await initPolls(for: user)
                        }
                        return
                    }
                    
                    
                    
                    self.pollSet.sort { $0.createdAt > $1.createdAt }
                    // Limit pollSet to the first 8 polls
                    self.pollSet = Array(self.pollSet.prefix(8))
                    // create array of poll ids
                    let pollIds = pollSet.map { $0.id }
                    UserDefaults.standard.setValue(pollIds, forKey: Constants.pollIds)
                    self.selectedPoll = pollSet[currentPollIndex]
                    allOptions = selectedPoll.pollOptions
                    self.getPollOptions(excludingUserId: user)
                    await updatePollOptionsInFB()
                    
                    updateQuestionEmoji()
                }
            }
            return
        }
        
        await initPolls(for: user)
    }
    
    func updatePollOptionsInFB() async {
        if self.selectedPoll.pollOptions.count != allOptions.count { // update in firebase
            self.selectedPoll.pollOptions = allOptions
            do {
                try await FirebaseService.shared.updateDocument(collection: "polls", field: "id", isEqualTo: selectedPoll.id, object: self.selectedPoll)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func initPolls(for user: User) async {
        print("initing polls bro")
        do {
            let polls: [Poll] = try await FirebaseService.shared.fetchDocuments(
                collection: "polls",
                whereField: "schoolId",
                isEqualTo: user.schoolId
            )
            
//            self.allPolls = polls.filter { question in
//                !Question.bsQuestions.contains { $0.question == question.title }
//            }
            
            self.allPolls = polls
            print(allPolls.count, "we yamaza")
            self.pollSet = polls.filter { !$0.usersWhoVoted.contains(user.id) }
            self.pollSet.sort { $0.createdAt > $1.createdAt }
            
            if pollSet.count < 8 {
                await createPoll(user: user)
            } else {
                for poll in pollSet {
                    self.selectedPoll = poll
                    allOptions = poll.pollOptions
                    getPollOptions(excludingUserId: user)
                    await updatePollOptionsInFB()
                }
            }
            
            // Limit pollSet to the first 8 polls
            self.pollSet = Array(self.pollSet.prefix(8))
            // create array of poll ids
            let pollIds = pollSet.map { $0.id }
            
            UserDefaults.standard.setValue(pollIds, forKey: Constants.pollIds)

            if let first = self.pollSet.first {
                self.selectedPoll = first
                allOptions = first.pollOptions
                self.getPollOptions(excludingUserId: user)
            }
          
        } catch {
            print("Error fetching polls: \(error.localizedDescription)")
        }
    }

    func answerPoll(user: User, option: PollOption, optionUser: User, totalVotes: Int) async {
        print("Answering poll for option: \(option.option)")
       
        if let optionIndex = selectedPoll.pollOptions.firstIndex(where: { $0.id == option.id }) {
            
            let currentDate = Date()
            let dateString = ISO8601DateFormatter().string(from: currentDate)
            
            // Update votes with the new structure
            if selectedPoll.pollOptions[optionIndex].votes == nil {
                selectedPoll.pollOptions[optionIndex].votes = [:]
            }
            
            
            if var voteObj = selectedPoll.pollOptions[optionIndex].votes?[user.id] {
                var currentVotes = Int(voteObj["numVotes"] ?? "100") ?? 100
                currentVotes += totalVotes
                selectedPoll.pollOptions[optionIndex].votes?[user.id] = [
                    "date": dateString,
                    "numVotes": String(currentVotes),
                    "viewedNotification": "false"
                ]
            } else {
                selectedPoll.pollOptions[optionIndex].votes?[user.id] = [
                    "date": dateString,
                    "numVotes": String(Int(totalVotes)),
                    "viewedNotification": "false"
                ]
            }
            
            selectedPoll.usersWhoVoted.append(user.id)
            
            if let index = pollSet.firstIndex(where: { $0.id == selectedPoll.id }) {
                pollSet[index] = selectedPoll
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
                    object: selectedPoll
                )
                
     
                
                var updatedOptionUser = optionUser
                updatedOptionUser.aura += totalVotes
                
                print("updated polls")
                
                try await FirebaseService.shared.updateDocument(
                    collection: "users",
                    object: user
                )
                
                try await FirebaseService.shared.updateDocument(
                    collection: "users",
                    object: updatedOptionUser
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
        print(" *******  *******  ******* creating polls  ******* ******* *******")

        var potentialQuestions = Question.bsQuestions.filter { question in
            !allPolls.contains { $0.title == question.question }
        }

        var newPolls: [Poll] = []
        while pollSet.count < 8 && !potentialQuestions.isEmpty {
            if let question = potentialQuestions.first {
                potentialQuestions.removeFirst()
           
                let id = UUID().uuidString
                selectedPoll.id = id
                
                allOptions = []
                getPollOptions(excludingUserId: user)

                let poll = Poll(
                    id: id,
                    title: question.question,
                    createdAt: Date(),
                    pollOptions: allOptions,
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
                allOptions = first.pollOptions
                self.getPollOptions(excludingUserId: user)
            }
        } catch {
            print("Error creating polls: \(error.localizedDescription)")
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
                votes: [:],
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
                votes: [:],
                gradeLevel: friend.grade
            )
            
            newOption.priorityScore = 5
            if newOption.gradeLevel == user.grade {
                newOption.priorityScore += 2
            }
            
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
                    votes: [:],
                    gradeLevel: userInGrade.grade
                )
                
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
                votes: [:],
                gradeLevel: remainUser.grade
            )
            
            allOptions.append(newOption)
        }
        
    }

    


    func getPollOptions(excludingUserId user: User) {
     
        // first get the top 10 most relavant options
        // priority #1
        
        var updatedOptions: [PollOption] = []
        var totalFriendOptions = 0
        var totalSameGradeOptions = 0
        for option in allOptions {
            var updatedOption = option
            let hasVotes = (option.votes?.values.reduce(0) { $0 + (Int($1["numVotes"] ?? "0") ?? 0) } ?? 0) > 0
            let isFriend = friends.contains { $0.id == option.userId }
            let sameGrade = friends.contains { $0.grade == option.gradeLevel }
            
            if hasVotes && isFriend {
                updatedOption.priorityScore += 7
                totalFriendOptions += 1
            } else if isFriend {
                totalFriendOptions += 1
                updatedOption.priorityScore += 5
            } else if hasVotes {
                updatedOption.priorityScore += 1
            }
            
            if sameGrade {
                updatedOption.priorityScore += 2
                totalSameGradeOptions += 1
                
            }
            
            updatedOptions.append(option)
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
            allOptions.sort { $0.priorityScore > $1.priorityScore }
        }
        
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
        updateTotalVotes()
        resetPollState()
        
        // Print debug information
        print("getPollOptions called")
        print("Selected poll has \(selectedPoll.pollOptions.count) total options")
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

    func updateTotalVotes() {
        totalVotes = selectedPoll.pollOptions.reduce(0) { total, option in
            total + (option.votes?.values.reduce(0) { $0 + (Int($1["numVotes"] ?? "0") ?? 0) } ?? 0)
        }
        print("Updated total votes: \(totalVotes)")
        objectWillChange.send()
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
            body: "Collect bread, and get ur aura up",
            date: notificationDate
        )
        
        Task {
            do {
                var updatedUser = user
                updatedUser.lastPollFinished = Date()
                updatedUser.aura += 300
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

    func resetState() {
        // Reset all relevant properties
        self.completedPoll = false
        self.cooldownEndTime = nil
        // Reset any other properties as needed
    }
}
