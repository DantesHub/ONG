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
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @State private var timer: Timer?
    @State private var showShareSheet = false
    
    let columns = [
        GridItem(.flexible(), spacing: -24),
        GridItem(.flexible(), spacing: -24),
        GridItem(.flexible(), spacing: -24),
        GridItem(.flexible(), spacing: -24)
    ]
    
    var body: some View {
        Group {
            if pollVM.completedPoll {
                PollComplete()
                    .environmentObject(pollVM)
            } else {
                ZStack {
                    Color.primaryBackground.ignoresSafeArea()
                    VStack(spacing: 0) {
                        if pollVM.isNewPollReady && pollVM.cooldownEndTime == nil {
                            Text("new polls are\navailable!")
                                .sfPro(type: .bold, size: .h1)
                                .foregroundColor(.white)
                                .padding(.top, 16)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                            VStack(spacing: 16) {
                                SharedComponents.PrimaryButton(
                                    title: "Start",
                                    action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
                                            pollVM.isNewPollReady = false
                                            mainVM.currentPage = .poll
                                            Analytics.shared.log(event: "PollCooldown: Tapped Start")
                                        }
                                    }
                                )
                            }
                            .padding(.horizontal, 24)
                        } else {
                            Text("new polls in")
                                .sfPro(type: .bold, size: .h1)
                                .foregroundColor(.white)
                                .padding(.top, 16)
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
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
                                            showShareSheet = true
                                        }
                                    }
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                   
                        

                  
                        Spacer()

                        VStack {
                            Text("aura leaders (today)")
                                .sfPro(type: .semibold, size: .h2)
                                .foregroundColor(.white)
                                .padding(.top, 32)
                            LazyVGrid(columns: columns, spacing: 24) {
                                ForEach(profileVM.topEight.prefix(8), id: \.id) { user in
                                    ZStack {
                                        if let url = URL(string: user.proPic), !user.proPic.isEmpty {
                                            CachedAsyncImage(url: url) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 64, height: 64)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                case .failure:
                                                    Image(systemName: "person.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 56, height: 56)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                case .empty:
                                                    ProgressView()
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .frame(width: 64, height: 64)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        } else {
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.gray)
                                        }
                                  
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.black.opacity(1), lineWidth: 4)
                                                    .padding(1)
                                                    .mask(RoundedRectangle(cornerRadius: 16))
                                            )
                                    }
                                    .frame(width: 64, height: 64)
                                    .cornerRadius(16)
                                    .primaryShadow()
                                    .rotationEffect(.degrees(-8))
                                    .onTapGesture {
                                        Analytics.shared.log(event: "PollCooldown: leaderboard tapped profile")
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
                                            profileVM.visitedUser = user
                                            profileVM.isVisitingUser = true
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                        
                        Spacer()
                        Spacer()
                    }
                    .padding(.top, 42)
                }  .sheet(isPresented: $showShareSheet) {
                    InviteFriendsModal()
                        .presentationDetents([.height(300)])
                        .presentationDragIndicator(.visible)
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
            .environmentObject(MainViewModel())
            .environmentObject(ProfileViewModel())

    }
}
