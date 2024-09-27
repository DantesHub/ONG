//
//  PollHelperFunctions.swift
//  ONG
//
//  Created by Dante Kim on 9/26/24.
//

import Foundation
import SwiftUI
import UIKit

extension PollScreen {
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
