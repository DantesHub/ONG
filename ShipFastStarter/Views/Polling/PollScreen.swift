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
    @State private var currentPollIndex = 0
    @State private var isComplete = false
    @State private var showTapToContinue = false
    @State private var animateProgress = false
    @State private var contentOpacity: Double = 1
    
    var body: some View {
        ZStack {
            Color.pink.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Story bar
                HStack(spacing: 4) {
                    ForEach(0..<min(pollVM.pollSet.count, 8), id: \.self) { index in
                        StoryProgressBar(isComplete: index <= currentPollIndex || (index == currentPollIndex && isComplete))
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
                               .padding(.top)
                            Text(pollVM.selectedPoll.title)
                                .sfPro(type: .bold, size: .h1)
                                .frame(height: 124, alignment: .top)
                                .padding(.horizontal, 24)
                                .multilineTextAlignment(.center)
                        }
                     
                        Spacer()
                        // Poll options in vertical layout
                        VStack(spacing: 24) {
                            ForEach(pollVM.currentFourOptions, id: \.id) { option in
                                PollOptionView(option: option, totalVotes: totalVotes, animateProgress: $animateProgress)
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
                            HStack {
                                Button(action: {
                                    skipPoll()
                                }) {
                                    Text("Skip")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(20)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    pollVM.shuffleOptions()
                                }) {
                                    Image(systemName: "shuffle")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(20)
                                }
                            }
                            .frame(height: 64)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                  
                        
                      
                    }
                    .opacity(contentOpacity)
                } else {
                    Text("No more polls available")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            print("test2")
            Task {
                await pollVM.getPollOptions()
            }
        }
        .onChange(of: pollVM.showProgress) {
            if pollVM.showProgress {
                showTapToContinue = true
                animateProgress = true
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if showTapToContinue {
                animateTransition()
            }
        }
    }
    
    private var totalVotes: Int {
        pollVM.currentFourOptions.reduce(0) { $0 + (($1.votes?.values.reduce(0, +)) ?? 0) }
    }
    
    private func skipPoll() {
        animateTransition()
    }
    
    private func animateTransition() {
        withAnimation(.easeInOut(duration: 0.3)) {
            contentOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            moveToNextPoll()
            
            withAnimation(.easeInOut(duration: 0.3)) {
                contentOpacity = 1
            }
        }
    }
    
    private func moveToNextPoll() {
        if currentPollIndex < pollVM.pollSet.count - 1 {
            currentPollIndex += 1
            isComplete = false
            pollVM.selectedPoll = pollVM.pollSet[currentPollIndex]
            Task {
                await pollVM.getPollOptions()
            }
            showTapToContinue = false
            animateProgress = false // Reset this local state
        }
    }
}

struct PollOptionView: View {
    @EnvironmentObject var pollVM: PollViewModel
    @EnvironmentObject var mainVM: MainViewModel
    let option: PollOption
    let totalVotes: Int
    @Binding var animateProgress: Bool
    @State private var progressWidth: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.opacity = 0.7
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring()) {
                    self.opacity = 1
                    if let user = mainVM.currUser {
                        Task {
                            await pollVM.answerPoll(user: user, option: option, totalVotes: 1)
                            withAnimation(.easeInOut(duration: 0.5)) {
                                pollVM.animateProgress = true
                                animateProgress = true // Update the local binding
                            }
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
                        
//                        if pollVM.showProgress {
//                            Spacer()
//                            Text("\(Int(progress * 100))%")
//                                .foregroundColor(.black)
//                                .sfPro(type: .semibold, size: .h3p1)
//                        }
                    }
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity, alignment: pollVM.showProgress ? .leading : .center)
                }
                .onChange(of: pollVM.animateProgress) {
                    if pollVM.animateProgress {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            progressWidth = geometry.size.width * progress
                        }
                    } else {
                        progressWidth = 0
                    }
                }
                .onChange(of: animateProgress) { newValue in
                    if newValue {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            progressWidth = geometry.size.width * progress
                        }
                    } else {
                        progressWidth = 0
                    }
                }
            }
        }
        .frame(height: 76)
        .scaleEffect(opacity == 1 ? 1 : 0.95)
        .disabled(pollVM.showProgress)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .primaryShadow()
    }
    
    private var progress: Double {
        guard totalVotes > 0 else { return 0 }
        let optionVotes = option.votes?.values.reduce(0, +) ?? 0
        return Double(optionVotes) / Double(totalVotes)
    }
}

struct StoryProgressBar: View {
    var isComplete: Bool
    
    var body: some View {
        Rectangle()
            .fill(isComplete ? Color.black : Color.black.opacity(0.25))
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
