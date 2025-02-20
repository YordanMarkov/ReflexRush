//
//  GameViewModel.swift
//  Reaction Timer Game
//
//  Created by Yordan Markov on 20.02.25.
//

import SwiftUI
import AVFoundation // For the sounds
import UIKit // For the vibrations


class GameViewModel: ObservableObject {
    @Published var startTime: Date?
    @Published var reactionTime: Double?
    @Published var gameMessage: String = "Shake your device to start!"
    @Published var isGameActive: Bool = false
    @Published var isStarted: Bool = false
    @Published var leaderboard: [Double] = []
    
    var audioPlayer: AVAudioPlayer?

    var backgroundColor: Color {
        gameMessage == "TAP!" ? .red : .white
    }

    func playSound(named soundName: String) {
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func vibrateNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }


    
    func startGame() {
        isStarted = true
        reactionTime = nil
        isGameActive = false
        gameMessage = "Get Ready!"

        DispatchQueue.global().async {
            for i in 1...3 {
                DispatchQueue.main.async {
                    self.gameMessage = "\(4-(i))"
                }
                self.playSound(named: "countdown-beep")
                self.vibrate(style: .light)
                sleep(1)
            }

            DispatchQueue.main.async {
                self.gameMessage = "Wait for it..."
            }

            let randomTimeInterval: Double = .random(in: 0.5...2.0)
            sleep(UInt32(randomTimeInterval))

            DispatchQueue.main.async {
                self.gameMessage = "TAP!"
                self.startTime = Date()
                self.isGameActive = true
            }
        }
    }

    func registerTap() {
        if isGameActive, let start = startTime {
            self.playSound(named: "tap-sound")
            self.vibrate(style: .medium)
            let elapsedTime = Date().timeIntervalSince(start)
            reactionTime = elapsedTime
            gameMessage = "You tapped!"
            isGameActive = false
            isStarted = false
            updateLeaderboard(time: elapsedTime)
        }
    }

    func updateLeaderboard(time: Double) {
        leaderboard.append(time)
        leaderboard.sort()
        if leaderboard.count > 10 {
            leaderboard.removeLast()
        }
    }
}
