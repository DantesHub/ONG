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
    @EnvironmentObject var pollVM: PollViewModel
    @EnvironmentObject var mainVM: MainViewModel
    
    @State private var emojiParticles: [EmojiParticle] = []
    @State private var emojiAnimationTimer: Timer?
    @State private var shootingTimer: Timer?
    @State private var touchLocation: CGPoint = .zero
    @State private var counterLocation: CGPoint = .zero
    @State private var counter: Int = 0
    @State private var isLongPressing: Bool = false
    
    @State private var randNumber: Int = Int.random(in: 0...7)
    @State private var isComplete: Bool = false
    @State private var showError: Bool = false
    @State private var shuffleCounter: Int = 0
    @State private var randPplNumber: Int = 0
    @State private var contentOpacity: Double = 1
    
    @State private var emojiShootingStage: EmojiShootingStage = .initial
    @State private var stagedEmojiIndex: Int = 0
    @State private var lastEmojiChangeCount: Int = 0
    
    let emojiList = ["🔥", "❤️‍🔥", "🌈", "✨", "💖", "🚀", "⚡️", "🎉", "🥹", "💫", "🙀"]
    
    // Increase this value to spawn more emojis
    private let emojisPerShot: Int = 10
    
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
            // Background color
            Color(Constants.colors[randNumber]).edgesIgnoringSafeArea(.all)
            
            // Emoji particles layer
            ForEach(emojiParticles) { particle in
                Text(particle.emoji)
                    .font(.system(size: 50))
                    .position(particle.position)
            }
            
            // Main content
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
                        // Poll options
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
            .onTapGesture {
                if pollVM.showProgress {
                    shuffleCounter = 0
                    animateTransition()
                }
            }
            
            // Counter display
            if isLongPressing {
                Text("\(counter)")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.black)
                    .padding(8)
                    .cornerRadius(8)
                    .position(x: activeButtonPosition.x, y: activeButtonPosition.y - 126)
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
            if pollVM.currentPollIndex ==  5  || pollVM.currentPollIndex == 2 {
                randPplNumber = Int.random(in: 0...2)
            }
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
    
    func startLongPressTimer(at location: CGPoint) {
        longPressStartTime = Date()
        isLongPressActivated = false
        emojiShootingStage = .initial
        stagedEmojiIndex = 0
        lastEmojiChangeCount = 0
        
        shootingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
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
        let speed = CGFloat.random(in: 5...15)
        
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
                self.emojiParticles[i].velocity.dy += 0.2
                self.emojiParticles[i].velocity.dx *= 0.99
            }
            
            self.emojiParticles.removeAll { particle in
                particle.position.y > UIScreen.main.bounds.height + 50 ||
                particle.position.x < -50 ||
                particle.position.x > UIScreen.main.bounds.width + 50 ||
                currentTime.timeIntervalSince(particle.creationTime) > 1.0
            }

            if self.emojiParticles.count > 500 {
                self.emojiParticles.removeFirst(self.emojiParticles.count - 500)
            }
        }
    }
    
    func stopEmojiAnimation() {
        emojiAnimationTimer?.invalidate()
        emojiAnimationTimer = nil
    }
}

struct PollOptionView: View {
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
    @State private var isLongPressActivated: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(1), lineWidth: 5)
                            .padding(1)
                            .mask(RoundedRectangle(cornerRadius: 16))
                    )
                
                // Option text
                Text(option.option)
                    .foregroundColor(.black)
                    .sfPro(type: .semibold, size: .h3p1)
            }
            .rotationEffect(isShaking ? .degrees(-5) : .degrees(0))
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
                    }
            )
        }
        .frame(height: 76)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .opacity(isSelected ? 1 : 0.3)
        .onAppear {
            setupHaptics()
            setupAudioPlayer()
        }
    }
    
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
        guard let soundURL = Bundle.main.url(forResource: "Stavan Patel's Video - Sep 11, 2024", withExtension: "mp3") else {
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
        counter = 0
        emojiChangeCounter = 0
        currentEmojiIndex = 0
        shouldActivate = true
        
        Timer.scheduledTimer(withTimeInterval: 0.0120, repeats: true) { timer in
            if shouldActivate {
                if counter == 0 {
                    counter = 1
                } else {
                    let maxValue: Double = 9_000_000
                    let growth: Double
                    
                    if counter < 400 {
                        growth = 0.2
                    } else if counter < 800 {
                        growth = counter * 0.0012
                    } else if counter < 1_000 {
                        growth = counter * 0.0008
                    } else if counter < 1_200 {
                        growth = counter * 0.00120
                    } else if counter < 12_000 {
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
        counter = 0
        updateCounter(0)
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
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            isLongPressActivated = true
            startAudio()
            onLongPressStart(buttonPosition, touchPosition)
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
