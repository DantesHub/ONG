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
    @State private var animateProgress = false
    
    var body: some View {
        ZStack {
            Color.red.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Story bar
                HStack(spacing: 4) {
                    ForEach(0..<pollVM.pollSet.count, id: \.self) { index in
                        StoryProgressBar(isComplete: index < currentPollIndex || (index == currentPollIndex && isComplete))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
                
                // Main content
                if !pollVM.pollSet.isEmpty {
                    VStack {
                        Spacer()
                        
                        // Emoji in the middle
                        Text("🤔")
                            .font(.system(size: 100))
                        
                        // Poll question
                        Text(pollVM.selectedPoll.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        // Poll options in vertical layout
                        VStack(spacing: 12) {
                            ForEach(pollVM.currentOptions.prefix(4), id: \.id) { option in
                                PollOptionView(option: option, totalVotes: totalVotes, animateProgress: $animateProgress)
                            }
                        }
                        .padding()
                        
                        // Skip and Shuffle buttons
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
                                pollVM.shufflePolls()
                            }) {
                                Image(systemName: "shuffle")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                } else {
                    Text("No more polls available")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            Task {
                await pollVM.getPollOptions()
            }
        }
    }
    
    private var totalVotes: Int {
        pollVM.currentOptions.reduce(0) { $0 + ($1.votes?.values.reduce(0, +) ?? 0) }
    }
    
    private func skipPoll() {
        if currentPollIndex < pollVM.pollSet.count - 1 {
            currentPollIndex += 1
            isComplete = false
            pollVM.selectedPoll = pollVM.pollSet[currentPollIndex]
            Task {
                await pollVM.getPollOptions()
            }
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
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            Analytics.shared.logActual(event: "PollScreen: Tapped Option", parameters: ["":""])
            if let user = mainVM.currUser {
                Task {
                    await pollVM.answerPoll(user: user, option: option)
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animateProgress = true
                    }                  
                }
            }
        }) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                if pollVM.showProgress {
                    Rectangle()
                        .fill(Color.blue.opacity(0.3))
                        .cornerRadius(8)
                        .frame(width: progressWidth)
                        .animation(.easeInOut(duration: 0.5), value: progressWidth)
                }
                
                Text(option.option)
                    .foregroundColor(.black)
                    .padding()
            }
        }
        .frame(height: 50)
        .disabled(pollVM.showProgress)
        .onChange(of: animateProgress) { newValue in
            if newValue {
                progressWidth = UIScreen.main.bounds.width * 0.8 * progress
            } else {
                progressWidth = 0
            }
        }
    }
    
    private var progress: Double {
        guard totalVotes > 0 else { return 0 }
        let optionVotes = option.votes?.values.reduce(0, +) ?? 0
        return Double(optionVotes) / Double(totalVotes)
    }
}

struct StoryProgressBar: View {
    let isComplete: Bool
    
    var body: some View {
        Rectangle()
            .foregroundColor(isComplete ? .white : .gray.opacity(0.3))
            .frame(height: 2)
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
