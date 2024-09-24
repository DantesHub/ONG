//
//  PollScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import SwiftUI
import CoreHaptics
import AVFoundation

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
    @State private var emojiParticles: [EmojiParticle] = []
    @State private var emojiAnimationTimer: Timer?
    @State private var shootingTimer: Timer?
    @State private var touchLocation: CGPoint = .zero
    @State private var counterLocation: CGPoint = .zero
    @State private var counter: Int = 0
    @State private var isLongPressing: Bool = false

    @State private var emojiShootingStage: EmojiShootingStage = .initial
    @State private var stagedEmojiIndex: Int = 0
    @State private var lastEmojiChangeCount: Int = 0

    let emojiList = ["🔥", "❤️‍🔥", "🌈", "✨", "💖", "🚀", "⚡️", "🎉", "🥹", "💫", "🙀"]

    // Increase this value to spawn more emojis
    private let emojisPerShot: Int = 5

    // Add this constant for the vertical offset
    private let emojiSpawnOffset: CGFloat = -80 // Adjust this value as needed

    enum EmojiShootingStage {
        case initial
        case staged
        case allEmojis
    }

    @State private var isLongPressActivated: Bool = false
    @State private var longPressStartTime: Date?

    @State private var activeButtonPosition: CGPoint = .zero

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
                                                }
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
                pollVM.allOptions = pollVM.selectedPoll.pollOptions
                pollVM.getPollOptions(excludingUserId: user)
                await pollVM.updatePollOptionsInFB()
            }

            pollVM.showProgress = false
            pollVM.animateProgress = false
            isComplete = false // Reset completion state for the new poll
        } else {
            // All polls completed
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

    // Animation functions

    func startLongPressTimer(at location: CGPoint) {
        longPressStartTime = Date()
        isLongPressActivated = false
        emojiShootingStage = .initial
        stagedEmojiIndex = 0
        lastEmojiChangeCount = 0

        shootingTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            guard let startTime = longPressStartTime else { return }
            let elapsedTime = Date().timeIntervalSince(startTime)

            if elapsedTime >= 0.3 && !isLongPressActivated {
                isLongPressActivated = true
                emojiShootingStage = .staged
            }

            if isLongPressActivated {
                switch emojiShootingStage {
                case .initial:
                    break
                case .staged:
                    shootStagedEmoji(at: touchLocation)
                    if counter - lastEmojiChangeCount >= 120 {
                        lastEmojiChangeCount = counter
                        stagedEmojiIndex += 1
                        if stagedEmojiIndex >= emojiList.count {
                            emojiShootingStage = .allEmojis
                        }
                    }
                case .allEmojis:
                    shootAllEmojis(at: touchLocation)
                }
            }
        }
    }

    func stopShootingEmojis() {
        shootingTimer?.invalidate()
        shootingTimer = nil
        isLongPressActivated = false
        longPressStartTime = nil
        emojiShootingStage = .initial
    }

    func shootStagedEmoji(at location: CGPoint) {
        let offsetLocation = CGPoint(x: location.x, y: location.y + emojiSpawnOffset)
        for _ in 0..<emojisPerShot {
            addEmoji(at: offsetLocation, emoji: emojiList[stagedEmojiIndex])
        }
    }

    func shootAllEmojis(at location: CGPoint) {
        let offsetLocation = CGPoint(x: location.x, y: location.y + emojiSpawnOffset)
        for _ in 0..<emojisPerShot {
            let randomEmojiIndex = Int.random(in: 0..<emojiList.count)
            addEmoji(at: offsetLocation, emoji: emojiList[randomEmojiIndex])
        }
    }

    func addEmoji(at location: CGPoint, emoji: String) {
        let angle = CGFloat.random(in: 0...(2 * .pi))

        // Calculate the elapsed time since the long press started
        let elapsedTime = Date().timeIntervalSince(longPressStartTime ?? Date())

        let speedRange: ClosedRange<CGFloat> = elapsedTime <= 30 ? 15...20 : 40...65
        let speed = CGFloat.random(in: speedRange)

        let particle = EmojiParticle(
            emoji: emoji,
            position: location,
            velocity: CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed),
            creationTime: Date()
        )

        emojiParticles.append(particle)
    }

    func startEmojiAnimation() {
        emojiAnimationTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            let currentTime = Date()
            for i in 0..<self.emojiParticles.count {
                self.emojiParticles[i].position.x += self.emojiParticles[i].velocity.dx
                self.emojiParticles[i].position.y += self.emojiParticles[i].velocity.dy
                self.emojiParticles[i].velocity.dy += 0.5 // Increased gravity
                self.emojiParticles[i].velocity.dx *= 0.98 // Reduced air resistance
            }

            self.emojiParticles.removeAll { particle in
                particle.position.y > UIScreen.main.bounds.height + 100 ||
                particle.position.x < -100 ||
                particle.position.x > UIScreen.main.bounds.width + 100 ||
                currentTime.timeIntervalSince(particle.creationTime) > 0.5 // Increased lifetime
            }

            if self.emojiParticles.count > 1000 { // Increased maximum particle count
                self.emojiParticles.removeFirst(self.emojiParticles.count - 1000)
            }
        }
    }

    func stopEmojiAnimation() {
        emojiAnimationTimer?.invalidate()
        emojiAnimationTimer = nil
    }
}

struct PollOptionView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @EnvironmentObject var pollVM: PollViewModel
    @EnvironmentObject var mainVM: MainViewModel
    let option: PollOption
    var isCompleted: Bool = false
    var isSelected: Bool = true

    var onLongPressStart: (CGPoint, CGPoint) -> Void // (buttonPosition, touchPosition)
    var onLongPressEnd: () -> Void
    var updateTouchLocation: (CGPoint) -> Void
    var updateCounter: (Int) -> Void

    @State private var isLongPressing = false
    @State private var isShaking = false
    @State private var hapticTimer: Timer?
    @State private var shakeTimer: Timer?
    @State private var counter: Double = 0
    @State private var counterTimer: Timer?
    @State private var emojiChangeCounter: Int = 0
    @State private var currentEmojiIndex: Int = 0
    @State private var shouldActivate: Bool = false

    @State private var audioPlayer: AVAudioPlayer?

    @State private var engine: CHHapticEngine?
    @State private var hapticStartTime: Date?

    @State private var longPressTimer: Timer?
    @State private var longPressStartTime: Date?
    @State private var isLongPressActivated: Bool = false
    @State private var progressWidth: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
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
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity, alignment: pollVM.showProgress ? .leading : .center)
            }
            .rotationEffect(isShaking ? .degrees(-0.7) : .degrees(0))
            .animation(isShaking ? Animation.linear(duration: 0.075).repeatForever(autoreverses: true) : .default, value: isShaking)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let buttonPosition = CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).minY)
                        let touchPosition = CGPoint(
                            x: value.location.x + geometry.frame(in: .global).minX,
                            y: value.location.y + geometry.frame(in: .global).minY
                        )
                        updateTouchLocation(touchPosition)
                        if !isLongPressing {
                            isLongPressing = true
                            longPressStartTime = Date()
                            hapticStartTime = Date()
                            scheduleHapticFeedback()
                            scheduleShaking()
                            startCounter()
                            scheduleLongPressActions(buttonPosition: buttonPosition, touchPosition: touchPosition)
                        }
                    }
                    .onEnded { _ in
                        isLongPressing = false
                        isLongPressActivated = false
                        stopShaking()
                        stopHapticFeedback()
                        cancelScheduledShaking()
                        stopCounter()
                        stopAudio()
                        longPressTimer?.invalidate()
                        onLongPressEnd()

                        // Determine if it's a tap
                        if let startTime = longPressStartTime {
                            let elapsedTime = Date().timeIntervalSince(startTime)
//                            if elapsedTime < 0.3 {
//                                // Treat as tap
//                                answerPoll()
//                            }
                            answerPoll()

                        } else {
                            // Treat as tap
                            answerPoll()
                        }
                    }
            )
            .onChange(of: pollVM.animateProgress) {
                updateProgressWidth(geometry: geometry)
            }
            .onChange(of: pollVM.totalVotes) {
                updateProgressWidth(geometry: geometry)
            }
            .onChange(of: pollVM.selectedPoll) {
                updateProgressWidth(geometry: geometry)
            }
        }
        .frame(height: 76)
//        .scaleEffect(opacity == 1 ? 1 : 0.95)
        .disabled(pollVM.showProgress)
//        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .drawingGroup()
        .shadow(color: Color.black, radius: 0, x: 0, y: isLongPressing ? 3 : 6)
        .offset(y: isLongPressing ? 3 : 0)
        .animation(.easeOut(duration: 0.2), value: isLongPressing)
        .opacity(isSelected ? 1 : 0.3)
        .onAppear {
            setupHaptics()
            setupAudioPlayer()
        }
    }

    private func answerPoll() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        self.opacity = 0.7
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring()) {
                self.opacity = 1
                mainVM.currUser?.votedPolls.append(pollVM.selectedPoll.id)
                if let user = mainVM.currUser {
                    Task {
                        if let optionUser = profileVM.peopleList.first { usr in
                            usr.id == option.userId
                        } {
                            await pollVM.answerPoll(user: user, option: option, optionUser: optionUser, totalVotes: Int(counter <= 100 ? 100 : counter))
                            counter = 100
                            updateCounter(Int(counter))
                        }
                    }
                }
            }
        }
    }

    // Helper functions

    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }

    private func scheduleHapticFeedback() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            guard let startTime = hapticStartTime else { return }
            let elapsedTime = Date().timeIntervalSince(startTime)

            if elapsedTime >= 0.5 {
                triggerHapticFeedback()
            }
        }
    }

    private func triggerHapticFeedback() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error.localizedDescription)")
        }
    }

    private func stopHapticFeedback() {
        hapticTimer?.invalidate()
        hapticTimer = nil
        hapticStartTime = nil
    }

    private func setupAudioPlayer() {
        // Replace "YourSoundFileName" with the actual name of your sound file
        guard let soundURL = Bundle.main.url(forResource: "holdDown", withExtension: "mp3") else {
            print("Sound file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
        } catch {
            print("Error setting up audio player: \(error.localizedDescription)")
        }
    }

    private func startAudio() {
        audioPlayer?.play()
    }

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
    }

    private func startCounter() {
        counter = 101
        emojiChangeCounter = 0
        currentEmojiIndex = 0
        shouldActivate = true

        counterTimer = Timer.scheduledTimer(withTimeInterval: 0.0120, repeats: true) { timer in
            if shouldActivate {
                if counter == 100 {
                    counter = 100
                } else {
                    let maxValue: Double = 9_000_000
                    let growth: Double

                    if counter < 500 {
                        growth = 0.2
                    } else if counter < 1100 {
                        growth = counter * 0.0012
                    } else if counter < 1_400 {
                        growth = counter * 0.0008
                    } else if counter < 1_800 {
                        growth = counter * 0.00120
                    } else if counter < 15_000 {
                        growth = counter * 0.0004
                    } else if counter < 120_000 {
                        growth = counter * 0.00120
                    } else if counter < 1_200_000 {
                        growth = counter * 0.0002
                    } else {
                        growth = counter * 0.0001
                    }

                    counter += min(growth, maxValue - counter)

                    emojiChangeCounter += 1
                    if emojiChangeCounter >= 120 {
                        emojiChangeCounter = 0
                        currentEmojiIndex += 1
                    }
                }

                updateCounter(Int(counter))
            } else {
                timer.invalidate()
            }
        }
    }

    private func stopCounter() {
        shouldActivate = false
        
    }

    private func scheduleShaking() {
        shakeTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            startShaking()
        }
    }

    private func cancelScheduledShaking() {
        shakeTimer?.invalidate()
        shakeTimer = nil
    }

    private func startShaking() {
        isShaking = true
    }

    private func stopShaking() {
        isShaking = false
    }

    private func scheduleLongPressActions(buttonPosition: CGPoint, touchPosition: CGPoint) {
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            isLongPressActivated = true
            startAudio()
            onLongPressStart(buttonPosition, touchPosition)
        }
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
