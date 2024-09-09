//
//  PollScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import SwiftUI

struct PollScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var pollVM: PollViewModel
    @State private var isComplete = false
    @State private var showTapToContinue = false
    @State private var contentOpacity: Double = 1  // Add this line
    @State private var showSplash = true  // Add this line
    @State private var showError = false
    @State private var randNumber = Int.random(in: 0...7)
    
    var body: some View {
        ZStack {
            Color(Constants.colors[randNumber]).edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    // Story bar
                    HStack(spacing: 4) {
                        ForEach(0..<min(pollVM.pollSet.count, 8), id: \.self) { index in
                            StoryProgressBar(isComplete: index <= pollVM.currentPollIndex || (index == pollVM.currentPollIndex && isComplete))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    // Main content
                    if !pollVM.pollSet.isEmpty {
                        VStack {
                            Spacer()
                            // Poll question
                            VStack(spacing: 0) {
                                Text(pollVM.questionEmoji)
                                    .font(.system(size: 64))
                                Text(pollVM.selectedPoll.title)
                                    .sfPro(type: .bold, size: .h1)
                                    .frame(height: 124, alignment: .top)
                                    .padding(.horizontal, 24)
                                    .multilineTextAlignment(.center)
                            }
                            
                            if showError {
                                Text("invalid username")
                                    .sfPro(type: .semibold, size: .h3p1)
                                    .foregroundColor(.red)
                            }
                            
                            Spacer()
                            // Poll options in vertical layout
                            VStack(spacing: 24) {
                                ForEach(pollVM.currentFourOptions, id: \.id) { option in
                                    PollOptionView(option: option)
                                }
                            }
                            .padding()
                            
                            // Skip and Shuffle buttons
                            if pollVM.showProgress {
                                HStack {
                                    Text("Tap to continue")
                                        .foregroundColor(.white)
                                        .sfPro(type: .bold, size: .h2)
                                        .padding(.bottom, 20)
                                }.frame(height: 64)
                                    .padding(.horizontal)
                                    .padding(.bottom, 20)
                                
                            } else {
                                HStack(alignment: .center) {
                                    Button(action: {
                                        if let user = mainVM.currUser {
                                            pollVM.shuffleOptions(excludingUserId: user.id)
                                        }
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.black.opacity(1), lineWidth: 5)
                                                        .padding(1)
                                                        .mask(RoundedRectangle(cornerRadius: 16))
                                                )
                                            Image(systemName: "shuffle")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 24, height: 24)
//                                                .padding()
                                                .foregroundColor(Color.black)
                                        }
                                       
                                    }.frame(width: 48, height: 48)
                                    .primaryShadow()
                                    
                                    Spacer()
                                    HStack(alignment: .center, spacing: 8) {
                                        HStack(spacing: -16) {
                                            ForEach(pollVM.randomizedPeople.indices.prefix(4), id: \.self) { index in
                                                let person = pollVM.randomizedPeople[index]
                                                ZStack {
                                                    Circle()
                                                        .fill(Color(person.1 ))
                                                        .stroke(Color(.black), lineWidth: 1)
                                                        .overlay(
                                                            Circle()
                                                                .stroke(Color.black.opacity(1), lineWidth: 1)
                                                                .padding(1)
                                                                .mask(RoundedRectangle(cornerRadius: 20))
                                                        )
                                                        .frame(width: 36, height: 36)
                                                        .drawingGroup()
                                                        .shadow(color: Color.black, radius: 0, x: 0, y: 2)
                                                    Text("\(person.0 == "boy" ? "👦" : "👧")")
                                                        .font(.system(size: 16))
                                                    //                                                      .padding(24)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .cornerRadius(20)
                                        .padding(.bottom, 8)
                                        Text("4 answering rn")
                                            .sfPro(type: .medium, size: .p3)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.black)
                                    }.offset(y: 6)
                                
                                    
                                    Spacer()
                                    Button(action: {
                                        skipPoll()
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.black.opacity(1), lineWidth: 5)
                                                        .padding(1)
                                                        .mask(RoundedRectangle(cornerRadius: 16))
                                                )
                                            Image(systemName: "forward.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 24, height: 24)
//                                                .padding()
                                                .foregroundColor(Color.black)
                                        }
                                       
                                    }.frame(width: 48, height: 48)
                                    .primaryShadow()
                                    
                                 
                                }
                                .frame(height: 64)
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                        }
                        .opacity(contentOpacity)  // Add this line
                    } else {
                        Text("No more polls available")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }.onTapGesture {
                    if pollVM.showProgress {
                        
                        animateTransition()
                    }
                }
        }
    }

    
     func skipPoll() {
        updateProgressBar()
        animateTransition()
    }
    
     func updateProgressBar() {
        if pollVM.currentPollIndex < pollVM.pollSet.count - 1 {
            isComplete = true
        }
    }
    
     func animateTransition() {
        withAnimation(.easeInOut(duration: 0.3)) {
            randNumber = Int.random(in: 0...7)
            contentOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let user = mainVM.currUser {
                moveToNextPoll(user: user)
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                contentOpacity = 1
            }
        }
    }
    
    func moveToNextPoll(user: User) {
        if pollVM.currentPollIndex < pollVM.pollSet.count - 1 {
            pollVM.currentPollIndex += 1
            UserDefaults.standard.setValue(pollVM.currentPollIndex, forKey: Constants.currentIndex)
            pollVM.selectedPoll = pollVM.pollSet[pollVM.currentPollIndex]
            Task {
                 pollVM.getPollOptions(excludingUserId: user.id)
            }
            print("over here")
            pollVM.showProgress = false
            pollVM.animateProgress = false
            isComplete = false // Reset completion state for the new poll
        } else {
            // All polls completed
            mainVM.currUser?.lastPollFinished = Date()
            pollVM.completedPoll = true
            mainVM.currentPage = .cooldown
            if let user = mainVM.currUser {
                UserDefaults.standard.setValue(0, forKey: Constants.currentIndex)
                pollVM.finishPoll(user: user)
            }
        }
    }
}

struct PollOptionView: View {
    @EnvironmentObject var pollVM: PollViewModel
    @EnvironmentObject var mainVM: MainViewModel
    let option: PollOption
    var isCompleted: Bool = false
    var isSelected: Bool = true
    @State private var progressWidth: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            self.opacity = 0.7
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring()) {
                    self.opacity = 1
                    if let user = mainVM.currUser {
                        Task {
                            await pollVM.answerPoll(user: user, option: option)
                            print("Answer poll completed")
                        }
                    }
                }
            }
        }) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(1), lineWidth: 5)
                                .padding(1)
                                .mask(RoundedRectangle(cornerRadius: 16))
                        )
                    if pollVM.showProgress {
                        Rectangle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: progressWidth)
                            .animation(.easeInOut(duration: 0.5), value: progressWidth)
                            .cornerRadius(16)
                    }
                    
                    HStack {
                        Text(option.option)
                            .foregroundColor(.black)
                            .sfPro(type: .semibold, size: .h3p1)
                        
                        if pollVM.showProgress {
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .foregroundColor(.black)
                                .sfPro(type: .semibold, size: .h3p1)
                        }
                    }
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity, alignment: pollVM.showProgress ? .leading : .center)
                }
                .onChange(of: pollVM.animateProgress) {
                    updateProgressWidth(geometry: geometry)
                }
                .onChange(of: pollVM.totalVotes) {
                    updateProgressWidth(geometry: geometry)
                }
                .onChange(of: pollVM.selectedPoll) { _ in
                    updateProgressWidth(geometry: geometry)
                }
            }
        }
        .frame(height: 76)
        .scaleEffect(opacity == 1 ? 1 : 0.95)
        .disabled(pollVM.showProgress)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .primaryShadow()
        .opacity(isSelected ? 1 : 0.3)
    }
    
    private func updateProgressWidth(geometry: GeometryProxy) {
        if pollVM.animateProgress {
            withAnimation(.easeInOut(duration: 0.5)) {
                progressWidth = geometry.size.width * progress
            }
        } else {
            progressWidth = 0
        }
    }
    
    private var progress: Double {
        guard pollVM.totalVotes > 0 else { return 0 }
        let optionVotes = calculateOptionVotes()
        let progress = Double(optionVotes) / Double(pollVM.totalVotes)
        return progress
    }
    
    private func calculateOptionVotes() -> Int {
        return pollVM.selectedPoll.pollOptions
            .first(where: { $0.id == option.id })?
            .votes?
            .values
            .reduce(0) { $0 + (Int($1["numVotes"] ?? "0") ?? 0) } ?? 0
    }
}

struct StoryProgressBar: View {
    var isComplete: Bool
    
    var body: some View {
        Rectangle()
            .fill(isComplete ? Color.black : Color.black.opacity(0.15))
            .frame(height: 4)
            .cornerRadius(4)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    PollScreen()
        .environmentObject(MainViewModel())
        .environmentObject(PollViewModel())
}
