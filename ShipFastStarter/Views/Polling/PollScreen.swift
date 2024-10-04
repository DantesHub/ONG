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
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var isComplete = false
    @State private var showTapToContinue = false
    @State private var contentOpacity: Double = 1
    @State private var showSplash = true
    @State private var showError = false
    @State private var randNumber = Int.random(in: 0...7)
    @State private var randPplNumber = Int.random(in: 0...2)
    @State private var shuffleCounter = 0

    // Animation-related state variables
    @State  var emojiParticles: [EmojiParticle] = []
    @State  var emojiAnimationTimer: Timer?
    @State  var shootingTimer: Timer?
    @State  var touchLocation: CGPoint = .zero
    @State  var counterLocation: CGPoint = .zero
    @State  var counter: Int = 0
    @State  var isLongPressing: Bool = false
    @State  var emojiShootingStage: EmojiShootingStage = .initial
    @State  var stagedEmojiIndex: Int = 0
    @State  var lastEmojiChangeCount: Int = 0
    @State  var displayTutorial: Bool = false
    @State  var isLongPressActivated: Bool = false
    @State  var longPressStartTime: Date?
    @State  var activeButtonPosition: CGPoint = .zero
    let emojiList = ["🔥", "❤️‍🔥", "🌈", "✨", "💖", "🚀", "⚡️", "🎉", "🥹", "💫", "🙀"]
    // Increase this value to spawn more emojis
     let emojisPerShot: Int = 5
    // Add this constant for the vertical offset
     let emojiSpawnOffset: CGFloat = -80 // Adjust this value as needed
    enum EmojiShootingStage {
        case initial
        case staged
        case allEmojis
    }

 

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
                                .sfPro(type: .bold, size: .h1Small)
                                .frame(height: 124, alignment: .top)
                                .padding(.horizontal, 24)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
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
                                PollOptionView(
                                    option: option,
                                    onLongPressStart: { buttonPosition, touchPosition in
                                        activeButtonPosition = buttonPosition
                                        isLongPressing = true
                                        startLongPressTimer(at: touchPosition)
                                    },
                                    onLongPressEnd: {
                                        isLongPressing = false
                                        stopShootingEmojis()
                                    },
                                    updateTouchLocation: { location in
                                        touchLocation = location
                                    },
                                    updateCounter: { newCount in
                                        counter = newCount
                                    }
                                )
                            }
                        }
                        .padding()

                        // Skip and Shuffle buttons
                        if pollVM.showProgress {
                            HStack {
                                Text("Tap to continue")
                                    .foregroundColor(.black)
                                    .sfPro(type: .bold, size: .h2)
                                    .padding(.bottom, 20)
                            }.frame(height: 64)
                                .padding(.horizontal)
                                .padding(.bottom, 20)

                        } else {
                            HStack(alignment: .center) {
                                if shuffleCounter < 2 {
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        Analytics.shared.log(event: "PollScreen: Tapped Shuffle")
                                        if let user = mainVM.currUser {
                                            pollVM.shuffleOptions(excludingUserId: user.id)
                                            shuffleCounter += 1
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
                                                .foregroundColor(Color.black)
                                        }

                                    }.frame(width: 48, height: 48)
                                        .primaryShadow()
                                }

                                Spacer()
                                HStack(alignment: .center, spacing: 8) {
                                    if randPplNumber != 0 {
                                        HStack(spacing: -16) {
                                            ForEach(pollVM.randomizedPeople.indices.prefix(randPplNumber), id: \.self) { index in
                                                let person = pollVM.randomizedPeople[index]
                                                ZStack {
                                                    Circle()
                                                        .fill(Color(person.1 ))
                                                        .stroke(Color(.black), lineWidth: 1.5)
                                                        .padding(3)
                                                    Text("\(person.0 == "boy" ? "👦" : "👧")")
                                                        .font(.system(size: 16))
                                                }
                                                .frame(width: 40, height: 40)
                                                .drawingGroup()
                                                .shadow(color: Color.black, radius: 0, x: 0, y: 2)
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .cornerRadius(20)
                                        .padding(.bottom, 8)
                                        Text("\(randPplNumber) answering rn")
                                            .sfPro(type: .medium, size: .p3)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.black)
                                        
                                    }
                                    

                                }.offset(y: 6)

                                Spacer()
                                Button(action: {
                                    Analytics.shared.log(event: "PollScreen: tapped Skip")
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation {
                                        shuffleCounter = 0
                                        skipPoll()
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
                                        Image(systemName: "forward.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
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
                    .opacity(contentOpacity)
                } else {
                    Text("No more polls available")
                        .font(.title)
                        .foregroundColor(.white)
     
                }
            }
            
            // Emoji particles layer
            ForEach(emojiParticles) { particle in
                Text(particle.emoji)
                    .font(.system(size: 50))
                    .position(particle.position)
                }
            // Counter display
            if isLongPressing {
                Text("\(counter)")
                    .foregroundColor(.white)
                    .sfPro(type: counter <= 150 ? .regular : counter <= 225  ? .medium : counter <= 300 ? .semibold : .bold, size: counter <= 150 ? .h1 : counter <= 225  ? .title : counter <= 300 ? .titleHuge : .animation)
                    .stroke(color: counter <= 150 ? .black : counter <= 225  ? .green : counter <= 300 ? Color("pink") : Color("primaryBackground"), width: 3)
                    .rotationEffect(.degrees(counter <= 150 ? 0 : counter <= 225  ? -2 : counter <= 300 ? -4 : -8))
                    .padding(8)
                    .cornerRadius(8)
                    .position(x: activeButtonPosition.x, y: activeButtonPosition.y - 100)
            }
            if displayTutorial {
                Color.black.edgesIgnoringSafeArea(.all)
                    .opacity(0.7)
            }
          
        }
        .onTapGesture {
            if pollVM.showProgress {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                shuffleCounter = 0
                animateTransition()
            }
        }
        .onAppear {          
            startEmojiAnimation()
            if !UserDefaults.standard.bool(forKey: Constants.finishedPollTutorial) {
                displayTutorial = true
            }
        }
        .sheet(isPresented: $displayTutorial) {
            TutorialModal(isPresented: $displayTutorial)
        }
        .onDisappear {
            stopShootingEmojis()
            stopEmojiAnimation()
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
            if pollVM.currentPollIndex == 5 || pollVM.currentPollIndex == 2 {
                randPplNumber = Int.random(in: 0...2)
            }
            contentOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let user = mainVM.currUser {
                moveToNextPoll(user: user)
                pollVM.updateQuestionEmoji()
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

            Task {
                pollVM.selectedPoll = pollVM.pollSet[pollVM.currentPollIndex]
                await pollVM.getPollOptions(excludingUserId: user) // this will recalculate priority scores for the new selected pll
                pollVM.updateQuestionEmoji()
                pollVM.currentTwelveOptions = Array(pollVM.allOptions.prefix(12)).shuffled()
                // Take up to 4 options from the available options
                pollVM.currentFourOptions = Array(pollVM.currentTwelveOptions.prefix(4))
                pollVM.currentPollOptionIndex = min(4, pollVM.allOptions.count)
            }

            pollVM.showProgress = false
            pollVM.animateProgress = false
            isComplete = false // Reset completion state for the new poll
        } else { // All polls completed
            mainVM.currUser?.lastPollFinished = Date()
            mainVM.currUser?.aura += 300
            mainVM.currUser?.bread += 300
            if let user = mainVM.currUser {
                UserDefaults.standard.setValue(0, forKey: Constants.currentIndex)
                mainVM.currUser?.lastPollFinished = Date()
                pollVM.completedPoll = true
                pollVM.finishPoll(user: user)
                Task {
                    await profileVM.fetchPeopleList(user: user)
                }
                pollVM.isNewPollReady = false
                pollVM.completedPoll = true
                mainVM.currentPage = .cooldown
            }
        }
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

struct EmojiParticle: Identifiable {
    let id = UUID()
    let emoji: String
    var position: CGPoint
    var velocity: CGVector
    let creationTime: Date
}



#Preview {
    PollScreen()
        .environmentObject(MainViewModel())
        .environmentObject(PollViewModel())
}


struct ConditionalDrawingGroup: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        if isActive {
            content.drawingGroup()
        } else {
            content
        }
    }
}
