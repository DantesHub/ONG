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
    @State private var tappedReveal = false
    
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
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                tappedReveal.toggle()
                            }
                        }
                    }
                }
                .frame(height: 76)
                
                }
            }
            .sheet(isPresented: $tappedReveal) {
                RevealModal()
          


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

struct RevealModal: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var showGodDetailView = false
    @State private var showRevealDetailView = true
    @State private var notEnoughBread = false

  var body: some View {
      ZStack {
          Color.black.edgesIgnoringSafeArea(.all)
          VStack {
              if !(showGodDetailView || showRevealDetailView) {
                  Text("see who sent it")
                      .sfPro(type: .bold, size: .h1)
                      .foregroundColor(.white)
                      .frame(maxWidth: .infinity, alignment: .center)
              }
              if !showRevealDetailView {
                  GeometryReader { geometry in
                      ZStack(alignment: .leading) {
                          RoundedRectangle(cornerRadius: 16)
                              .fill(Color.primaryBackground)
                              .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "00278D").opacity(0.7), lineWidth: 4)
                                    .padding(1)
                                    .mask(RoundedRectangle(cornerRadius: 16))
                              )
                          VStack(spacing: 12) {
                              HStack {
                                  VStack(spacing: -28) {
                                      Text("god")
                                          .sfPro(type: .bold, size: .h1Big)
                                          .stroke(color: .black, width: 3)
                                      Text("mode")
                                          .sfPro(type: .bold, size: .h1Big)
                                          .stroke(color: .black, width: 3)
                                  }.foregroundColor(.white)
                                      .rotationEffect(.degrees(-16))
                                      .shadow(color: .black, radius: 0, x: 3, y: 3)
                                  
                                      .frame(maxWidth: .infinity, alignment: .center)
                              }
                              .padding(.horizontal, 32)
                              Text("🍞 40,000")
                                  .padding(4)
                                  .foregroundColor(.white)
                                  .sfPro(type: .semibold, size: .p3)
                                  .background(Capsule().fill(.black))
                          }
                          
                      }
                      .drawingGroup()
                      .shadow(color: Color(hex: "00278D"), radius: 0, x: 0, y: 6)
                      .padding(.horizontal)
                      .onTapGesture {
                          UIImpactFeedbackGenerator(style: .light).impactOccurred()
                          withAnimation {
                              
                          }
                      }
                      
                      Text("lasts 1 week")
                          .sfPro(type: .bold, size: .h3p1)
                          .foregroundColor(.white.opacity(0.8))
                          .opacity(0.7)
                          .offset(x: 245, y: 12)
                      ZStack {
                          Text("👀")
                              .font(.system(size: 48))
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .shadow(color: .black, radius: 0, x: 3, y: 3)
                              .offset(x: 16, y: 0)
                          Text("🧿")
                              .font(.system(size: 36))
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 84, y: 32)
                          Text("🧿")
                              .font(.system(size: 42))
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 72, y: 128)
                          Text("👀")
                              .font(.system(size: 42))
                              .padding(12)
                              .rotationEffect(.degrees(16))
                              .shadow(color: .black, radius: 0, x: 3, y: 3)
                              .offset(x: 32, y: 72)
                          Text("👀")
                              .font(.system(size: 48))
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .shadow(color: .black, radius: 0, x: 3, y: 3)
                              .offset(x: 242, y: 24)
                          Text("🧿")
                              .font(.system(size: 36))
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 300, y: 32)
                          Text("🧿")
                              .font(.system(size: 32))
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 248, y: 128)
                          Text("👀")
                              .font(.system(size: 42))
                              .padding(12)
                              .rotationEffect(.degrees(16))
                              .shadow(color: .black, radius: 0, x: 3, y: 3)
                              .offset(x: 300, y: 84)
                      }.opacity(0.75)
                      
                  }
                  .frame(height: 204)
                  .onTapGesture {
                      UIImpactFeedbackGenerator(style: .light).impactOccurred()
                      withAnimation {
                          Analytics.shared.log(event: "RevealModal: Tapped God Mode")
                          showGodDetailView.toggle()
                      }
                  }
              }
              if showGodDetailView {
                  VStack(spacing: 0) {
                      Text("Features")
                          .sfPro(type: .bold, size: .h2)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding([.top, .horizontal], 24)
                      VStack(alignment: .leading, spacing: -12) {
                          Text("· Unlimited first letter reveals")
                              .sfPro(type: .bold, size: .h3p1)
                              .padding(8)
                          Text("· 2 full name reveals")
                              .sfPro(type: .bold, size: .h3p1)
                              .padding(8)
                          Text("· 4 shields (no one can reveal you)")
                              .sfPro(type: .bold, size: .h3p1)
                              .padding(8)
                          Text("· custom app icon")
                              .sfPro(type: .bold, size: .h3p1)
                              .padding(8)
                          Text("· custom profile frame")
                              .sfPro(type: .bold, size: .h3p1)
                              .padding(8)
                      }
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .padding(.horizontal, 24)
                  }.foregroundColor(.white)
                  if notEnoughBread {
                      Text("you don't have enough bread. you can more bread by doing more polls or")
                          .sfPro(type: .semibold, size: .p2)
                          .foregroundColor(.red)
                          .multilineTextAlignment(.center)
                          .padding(.horizontal)
                          .padding(.vertical, 4)
                      Text("buy more here")
                          .sfPro(type: .semibold, size: .h3p1)
                          .foregroundColor(.white)
                          .multilineTextAlignment(.center)
                          .padding(.horizontal)
                          .underline()
                          .onTapGesture {
                              Analytics.shared.log(event: "GodMode: Tapped Buy More")
                              UIImpactFeedbackGenerator(style: .light)
                              withAnimation {
                                  
                              }
                          }
                  }
                  ZStack(alignment: .leading) {
                      RoundedRectangle(cornerRadius: 16)
                          .fill(Color.primaryBackground)
                          .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "00278D").opacity(0.7), lineWidth: 4)
                                .padding(1)
                                .mask(RoundedRectangle(cornerRadius: 16))
                          )
                      HStack {
                          Text("activate god mode")
                              .sfPro(type: .bold, size: .h3p1)
                              .foregroundColor(.white)
                              .frame(maxWidth: .infinity, alignment: .center)
                      }
                      .padding(.horizontal, 32)
                  }
                  .drawingGroup()
                  .shadow(color: Color(hex: "00278D"), radius: 0, x: 0, y: 6)
                  .frame(height: 72)
                  .padding()
              }
              if !(showGodDetailView || showRevealDetailView) {
                  Text("---- or ----")
                      .sfPro(type: .bold, size: .h2)
                      .foregroundColor(.white.opacity(0.5))
                      .padding(.vertical)
              }
           
              if !showGodDetailView {
                  GeometryReader { geometry in
                      ZStack(alignment: .leading) {
                          RoundedRectangle(cornerRadius: 16)
                              .fill(Color.primaryRed)
                              .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.darkRed, lineWidth: 4)
                                    .padding(1)
                                    .mask(RoundedRectangle(cornerRadius: 16))
                              )
                          VStack(spacing: 0) {
                              HStack {
                                  VStack(spacing: -20) {
                                      Text("reveal")
                                          .sfPro(type: .bold, size: .h1)
                                          .stroke(color: .black, width: 3)
                                      Text("first")
                                          .sfPro(type: .bold, size: .h1)
                                          .stroke(color: .black, width: 3)
                                      Text("letter")
                                          .sfPro(type: .bold, size: .h1)
                                          .stroke(color: .black, width: 3)
                                  }.foregroundColor(.white)
                                      .shadow(color: .black, radius: 0, x: 1, y: 1)
                                      .frame(maxWidth: .infinity, alignment: .center)
                              }
                              .padding(.horizontal, 32)
                              Text("🍞 5,000")
                                  .padding(4)
                                  .foregroundColor(.white)
                                  .sfPro(type: .semibold, size: .p3)
                                  .background(Capsule().fill(.black))
                          }
                          
                      }
                      .drawingGroup()
                      .shadow(color: Color.darkRed, radius: 0, x: 0, y: 6)
                      .padding(.horizontal)
                      .onTapGesture {
                          UIImpactFeedbackGenerator(style: .light).impactOccurred()
                          withAnimation {
                            
                          }
                      }
                      ZStack {
                          // Existing letters
                          Text("A")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 1.5)
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 16, y: 0)
                          Text("S")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black)
                              .padding(12)
                              .rotationEffect(.degrees(16))
                              .offset(x: 72, y: 32)
                          Text("J")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h2)
                              .stroke(color: .black)
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 72, y: 100)
                          Text("K")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 1.4)
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 32, y: 64)
                          Text("B")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 2)
                              .padding(12)
                              .rotationEffect(.degrees(12))
                              .offset(x: 242, y: 0)
                          Text("C")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 1)
                              .padding(12)
                              .rotationEffect(.degrees(64))
                              .offset(x: 300, y: -12)
                          Text("N")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 2)
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 312, y: 32)
                          Text("D")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h2)
                              .stroke(color: .black, width: 1)
                              .padding(12)
                              .rotationEffect(.degrees(24))
                              .offset(x: 254, y: 48)
                          Text("P")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 2)
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 248, y: 96)
                          Text("M")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h2)
                              .stroke(color: .black, width: 1)
                              .padding(12)
                              .rotationEffect(.degrees(16))
                              .offset(x: 300, y: 84)
                          
                          // New letters
                          Text("E")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h3)
                              .stroke(color: .black, width: 1)
                              .padding(12)
                              .rotationEffect(.degrees(-8))
                              .offset(x: 100, y: -10)
                          Text("F")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h2)
                              .stroke(color: .black, width: 1.2)
                              .padding(12)
                              .rotationEffect(.degrees(20))
                              .offset(x: 280, y: 120)
                          Text("G")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 1.5)
                              .padding(12)
                              .rotationEffect(.degrees(-12))
                              .offset(x: 20, y: 110)
                          Text("H")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h3)
                              .stroke(color: .black, width: 1)
                              .padding(12)
                              .rotationEffect(.degrees(15))
                              .offset(x: 100, y: 80)
                          //                      Text("I")
                          //                          .foregroundColor(Color.primaryRed)
                          //                          .sfPro(type: .bold, size: .h2)
                          //                          .stroke(color: .black, width: 1.3)
                          //                          .padding(12)
                          //                          .rotationEffect(.degrees(-5))
                          //                          .offset(x: 160, y: -12)
                      }
                  }
                  .frame(height: 174)
                  .onTapGesture {
                      UIImpactFeedbackGenerator(style: .light).impactOccurred()
                      withAnimation {
                          Analytics.shared.log(event: "RevealModal: Tapped Reveal Letter")
                      }
                  }
              }
              
              if showRevealDetailView {
                  VStack(spacing: 0) {
                      Text("unlocking this will give you the first letter of the person that gave u aura for this poll.")
                          .sfPro(type: .bold, size: .h2)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding([.top, .horizontal], 24)
                          .multilineTextAlignment(.center)
                  }.foregroundColor(.white)
                  Text("you don't have enough bread. you can more bread by doing more polls or")
                      .sfPro(type: .semibold, size: .p2)
                      .foregroundColor(.red)
                      .multilineTextAlignment(.center)
                      .padding(.horizontal)
                      .padding(.vertical, 8)
                  Text("buy more here")
                      .sfPro(type: .semibold, size: .h3p1)
                      .foregroundColor(.white)
                      .multilineTextAlignment(.center)
                      .padding(.horizontal)
                      .underline()
                  ZStack(alignment: .leading) {
                      RoundedRectangle(cornerRadius: 16)
                          .fill(Color.primaryRed)
                          .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.darkRed.opacity(0.7), lineWidth: 4)
                                .padding(1)
                                .mask(RoundedRectangle(cornerRadius: 16))
                          )
                      HStack {
                          Text("reveal for 5000 🍞")
                              .sfPro(type: .bold, size: .h3p1)
                              .foregroundColor(.white)
                              .frame(maxWidth: .infinity, alignment: .center)
                      }
                      .padding(.horizontal, 32)
                  }
                  .drawingGroup()
                  .shadow(color: Color.darkRed, radius: 0, x: 0, y: 6)
                  .frame(height: 72)
                  .padding()
                  .onTapGesture {
                      UIImpactFeedbackGenerator(style: .light).impactOccurred()
                      withAnimation {
                          
                      }
                  }
              }
          }
      }
  }
}


//#Preview {
//    PollAnswerDetailView()
//        .environmentObject(InboxViewModel())
//        .environmentObject(MainViewModel())
//}

#Preview {
    RevealModal()
        .environmentObject(InboxViewModel())
        .environmentObject(MainViewModel())
}
