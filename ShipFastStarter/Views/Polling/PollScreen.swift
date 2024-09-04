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
                if let currentPoll = pollVM.pollSet[safe: currentPollIndex] {
                    VStack {
                        Spacer()
                        
                        // Emoji in the middle (you might want to add this to your Poll model)
                        Text("🤔")
                            .font(.system(size: 100))
                        
                        // Poll question
                        Text(currentPoll.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                        
                        Spacer()
                        
                        // 4 Poll options in 2x2 grid
                        VStack(spacing: 12) {
                            ForEach(0..<pollVM.currentOptions.count, id: \.self) { index in
                                if index % 2 == 0 {
                                    HStack(spacing: 12) {
                                        PollOptionView(option: pollVM.currentOptions[index])
                                        if index + 1 < pollVM.currentOptions.count {
                                            PollOptionView(option: pollVM.currentOptions[index + 1])
                                        } else {
                                            Spacer()
                                        }
                                    }
                                }
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
                    Text("No polls available")
                }
            }
        }
    }
    
    private func skipPoll() {
        if currentPollIndex < pollVM.pollSet.count - 1 {
            currentPollIndex += 1
            isComplete = false
            if let nextPoll = pollVM.pollSet[safe: currentPollIndex] {
                pollVM.selectedPoll = nextPoll
                pollVM.getPollOptions()
            }
        }
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

struct PollOptionView: View {
    let option: PollOption
    
    var body: some View {
        Button(action: {
            // Handle option selection
        }) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Rectangle()
                    .fill(Color.blue.opacity(0.3))
                    .cornerRadius(8)
                    .frame(width: abs(UIScreen.main.bounds.width * 0.4 * option.computedProgress))
                
                Text(option.option)
                    .foregroundColor(.black)
                    .padding()
            }
        }
        .frame(height: 50)
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
