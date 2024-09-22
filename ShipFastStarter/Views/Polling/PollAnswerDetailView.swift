//
//  PollAnswerDetailView.swift
//  ONG
//
//  Created by Dante Kim on 9/22/24.
//

import Foundation
import SwiftUI


struct PollAnswerDetailView: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var mainVM: MainViewModel

    var body: some View {
        ZStack {
            Color.lightPurple.edgesIgnoringSafeArea(.all)
            VStack {
                // Poll question
                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                inboxVM.tappedNotification = false
                            }
                        Spacer()
                        Text(inboxVM.selectedInbox?.gender == "boy" ? "👦🏼" : "👧🏼")
                            .font(.system(size: 40))
                            .frame(width: 60, height: 60)
                            .background(inboxVM.selectedInbox?.backgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 8)
                            )
                            .cornerRadius(8)
                            .rotationEffect(.degrees(-12))
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .opacity(0)
                    }.padding([.top, .horizontal], 32)
             
                    Text("from a \(inboxVM.selectedInbox?.gender ?? "boy") in \(inboxVM.selectedInbox?.grade ?? "")")
                        .sfPro(type: .semibold, size: .h3p1)
                        .padding(.top)
                    Spacer()
                    Text(inboxVM.selectedPoll?.title ?? "")
                        .sfPro(type: .bold, size: .h2)
                        .frame(height: 100, alignment: .top)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                // Poll options in vertical layout
                VStack(spacing: 24) {
                    ForEach(Array(inboxVM.currentFourOptions.enumerated()), id: \.element.id) { index, option in
                        OriginalPollOptionView(option: option, isCompleted: true, isSelected: index == 0)
                    }
                }
                .padding()
                HStack {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "2A2A2A"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black.opacity(0.7), lineWidth: 5)
                                        .padding(1)
                                        .mask(RoundedRectangle(cornerRadius: 16))
                                )
                            HStack {
                                Text("reveal a letter 🤐")
                                    .sfPro(type: .bold, size: .h3p1)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.horizontal, 32)
                        }
                        .primaryShadow()
                        .padding(.horizontal)
                    }
                }
                .frame(height: 76)
                
                }
            }
        }
      
    
    
    struct OriginalPollOptionView: View {
        @EnvironmentObject var pollVM: PollViewModel
        @EnvironmentObject var mainVM: MainViewModel
        let option: PollOption
        var isCompleted: Bool = false
        var isSelected: Bool = true
        @State private var progressWidth: CGFloat = 0
        @State private var opacity: Double = 1
        
        var body: some View {
            Button(action: {
//                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                self.opacity = 0.7
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    withAnimation(.spring()) {
//                        self.opacity = 1
//                        if let user = mainVM.currUser {
//                            Task {
//                                await pollVM.answerPoll(user: user, option: option)
//                                print("Answer poll completed")
//                            }
//                        }
//                    }
//                }
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
}

#Preview {
    PollAnswerDetailView()
        .environmentObject(InboxViewModel())
        .environmentObject(MainViewModel())
}
