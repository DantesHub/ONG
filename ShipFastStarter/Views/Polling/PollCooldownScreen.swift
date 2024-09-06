//
//  PollComplete.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import SwiftUI

struct PollCooldownScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var pollVM: PollViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @State private var timer: Timer?

    var body: some View {
        Group {
            if pollVM.completedPoll {
                PollComplete()
                    .environmentObject(pollVM)
            } else {
                ZStack {
                    Color.primaryBackground.ignoresSafeArea()
                    VStack(spacing: 0) {
                        Text("new polls in")
                            .sfPro(type: .bold, size: .h1)
                            .foregroundColor(.white)
                        Text("\(pollVM.timeRemainingString())")
                            .sfPro(type: .bold, size: .title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                            Text("--- or ---")
                                .sfPro(type: .semibold, size: .h2)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.vertical, 32)
                        

                        VStack(spacing: 16) {
                            Text("skip the wait!")
                                .sfPro(type: .semibold, size: .h2)
                                .foregroundColor(.white)
                            SharedComponents.PrimaryButton(
                                title: "Invite a friend",
                                action: {
                                    // Implement skip the wait functionality
                                }
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // HStack(spacing: 24) {
                        //     ForEach(["🔥", "😂", "😍", "👀", "💯"], id: \.self) { emoji in
                        //         Text(emoji)
                        //             .font(.system(size: 40))
                        //     }
                        // }
                        // .padding(.bottom, 32)
                    }
                    .padding(.top, 64)
                }
            }
       
        }.onAppear {
            if let user = mainVM.currUser {
                pollVM.checkCooldown(user: user)
                startTimer()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
     
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let cooldownEndTime = pollVM.cooldownEndTime, cooldownEndTime <= Date() {
                pollVM.cooldownEndTime = nil
                timer?.invalidate()
            }
        }
    }

 
}

struct PollCooldownScreen_Previews: PreviewProvider {
    static var previews: some View {
        PollCooldownScreen()
            .environmentObject(PollViewModel())
    }
}
