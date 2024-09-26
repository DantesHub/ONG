//
//  ColorScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/7/24.
//

import SwiftUI

struct ColorScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var pollVM: PollViewModel

    let columns = [
         GridItem(.flexible()),
         GridItem(.flexible())
     ]
    
    var body: some View {
        VStack {
            Text("finally, pick a color")
                .sfPro(type: .bold, size: .h1)
            .foregroundColor(.black)
            Text("keep this a secret 🤫")
                .sfPro(type: .medium, size: .h2)
                .foregroundColor(.gray)
            VStack {
                HStack {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Constants.colors.indices, id: \.self) { index in
                            borderedRectangle(color: Color(Constants.colors[index]))
                                .aspectRatio(1, contentMode: .fit)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation {
                                        Analytics.shared.log(event: "ColorsScreen: Tapped Color")
                                        mainVM.currUser?.color = Constants.colors[index]
                                        UserDefaults.standard.setValue(true, forKey: "finishedOnboarding")
                                        
                                        if let currUser = mainVM.currUser {
                                            Task {
                                                try await FirebaseService.shared.updateDocument(collection: "users", object: currUser)
                                                await pollVM.fetchPolls(for: currUser)
                                                
                                                if !pollVM.allPolls.isEmpty {
                                                    // Filter polls created in the last 2 days
                                                    let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
                                                    let recentPolls = pollVM.allPolls.filter { $0.createdAt >= sevenDaysAgo }
                                                    
                                                    // Create a new poll option for the current user
                                                    let newOption = PollOption(
                                                        id: UUID().uuidString,
                                                        type: "Poll",
                                                        option: "\(currUser.firstName) \(currUser.lastName)",
                                                        userId: currUser.id,
                                                        votes: [:],
                                                        gradeLevel: currUser.grade
                                                    )
                                                    
                                                    // Add the new option to all recent polls and prepare for batch update
                                                    var updatedPolls: [Poll] = []
                                                    for var poll in recentPolls {
                                                        if !poll.pollOptions.contains(where: { $0.userId == currUser.id }) {
                                                            poll.pollOptions.append(newOption)
                                                            updatedPolls.append(poll)
                                                        }
                                                    }
                                                    
                                                    // Batch update the polls in Firebase
                                                    if !updatedPolls.isEmpty {
                                                        do {
                                                            try await FirebaseService.shared.batchUpdate(collection: "polls", objects: updatedPolls)
                                                            print("Successfully updated \(updatedPolls.count) polls with the new user")
                                                        } catch {
                                                            print("Error updating polls with new user: \(error.localizedDescription)")
                                                        }
                                                    }
                                                }
                                                
                                                Analytics.shared.identifyUser(user: currUser)
                                            }
                                        }
                                        
                                        pollVM.isNewPollReady = true
                                        mainVM.currentPage = .cooldown
                                    }
                                }
                        }
                    }.padding()
                }
            }
        }
    }
    
    func borderedRectangle(color: Color) -> some View {
           ZStack {
               RoundedRectangle(cornerRadius: 16)
                   .fill(color) // Light green color
                   .overlay(
                       RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(1), lineWidth: 3)
                         .padding(1)
                         .mask(RoundedRectangle(cornerRadius: 16))
                   )
            }
           .frame(width: 156, height: 124) // Adjust height as needed
           .primaryShadow()
       }
}

#Preview {
    ColorScreen()
}
