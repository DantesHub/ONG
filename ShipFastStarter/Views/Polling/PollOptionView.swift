//
//  PollOptionView.swift
//  ONG
//
//  Created by Dante Kim on 9/26/24.
//

import SwiftUI
import CoreHaptics
import AVFoundation

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
    
    private func answerPoll() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        self.opacity = 0.7
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring()) {
                self.opacity = 1
                if let user = mainVM.currUser {
                    Task {
                        if let optionUser = profileVM.peopleList.first(where: { usr in
                            usr.id == option.userId
                        }) {
                            await pollVM.answerPoll(user: user, option: option, optionUser: optionUser, totalVotes: Int(counter <= 100 ? 100 : counter))
                            counter = 100
                            updateCounter(Int(counter))
                        }
                    }
                }
            }
        }
    }


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
                        if !pollVM.showProgress {
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
            .onChange(of: pollVM.selectedPoll.voteSummary) { _ in
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

    
    
    
    
    
    //MARK: - Helper functions
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
                    let maxValue: Double = 5000
                    let growth: Double

                    if counter < 500 {
                        growth = 0.2
                    } else if counter < 1100 {
                        growth = counter * 0.0012
                    } else if counter < 1_400 {
                        growth = counter * 0.0008
                    } else if counter < 1_800 {
                        growth = counter * 0.00120
                    } else if counter < 3000 {
                        growth = counter * 0.0004
                    } else if counter < 4000 {
                        growth = counter * 0.00120
                    } else if counter < 5000 {
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
        let totalVotes = pollVM.selectedPoll.voteSummary.values.reduce(0, +)
        guard totalVotes > 0 else { return 0 }
        let optionVotes = pollVM.selectedPoll.voteSummary[option.userId] ?? 0
        return Double(optionVotes) / Double(totalVotes)
    }
}

